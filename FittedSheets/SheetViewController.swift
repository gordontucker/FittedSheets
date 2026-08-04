//
//  SheetViewController.swift
//  FittedSheetsPod
//
//  Created by Gordon Tucker on 7/29/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

#if os(iOS)
import UIKit

/// A snapshot of the sheet's live progress across its defined detents, computed by the library and
/// delivered every frame the height moves (see `SheetViewController.progressChanged`). Consumers use
/// it to drive progressive/interactive content without needing to know the detent heights themselves.
public struct SheetHeightProgress {
    /// One entry per defined detent, ordered smallest → largest by height.
    public struct Step {
        /// The detent this step represents.
        public let size: SheetSize
        /// The detent's current content height, in points.
        public let height: CGFloat
        /// Progress of the segment leading up to this detent, 0…1: it stays 0 until the sheet leaves
        /// the previous detent, ramps to 1 across the gap, and remains 1 once the height passes this
        /// detent. The smallest detent's `reveal` is always 1. Drive content that "unlocks" at a
        /// given detent from `steps[i].reveal`.
        public let reveal: CGFloat
    }

    /// The live on-screen content height, in points.
    public let height: CGFloat
    /// Overall progress across all detents: 0 at the smallest detent, 1 at the largest. Clamped.
    public let fraction: CGFloat
    /// The largest detent the sheet has currently reached (its height ≤ `height`).
    public let reachedSize: SheetSize
    /// Index of `reachedSize` within `steps`.
    public let reachedIndex: Int
    /// Per-detent progress, smallest → largest.
    public let steps: [Step]
}

public class SheetViewController: UIViewController {
    public private(set) var options: SheetOptions
    
    /// Default value for autoAdjustToKeyboard. Defaults to true.
    public static var autoAdjustToKeyboard = true
    /// Automatically grow/move the sheet to accomidate the keyboard. Defaults to false.
    public var autoAdjustToKeyboard = SheetViewController.autoAdjustToKeyboard
    
	/// Default value for allowPullingPastMaxHeight. Defaults to true.
	public static var allowPullingPastMaxHeight = true
    /// Allow pulling past the maximum height and bounce back. Defaults to true.
    public var allowPullingPastMaxHeight = SheetViewController.allowPullingPastMaxHeight
    
	/// Default value for allowPullingPastMinHeight. Defaults to true.
	public static var allowPullingPastMinHeight = true
	/// Allow pulling below the minimum height and bounce back. Defaults to true.
	public var allowPullingPastMinHeight = SheetViewController.allowPullingPastMinHeight
    
    /// The sizes that the sheet will attempt to pin to. Defaults to intrinsic only.
    public var sizes: [SheetSize] = [.intrinsic] {
        didSet {
            self.updateOrderedSizes()
        }
    }
    public var orderedSizes: [SheetSize] = []
    public private(set) var currentSize: SheetSize = .intrinsic

    /// Duration of the smooth animation used when the sheet auto-resizes to fit an intrinsic
    /// content-height change. Defaults to a gentle 0.35s (vs. the snappier detent-snap timing).
    public var intrinsicTransitionDuration: TimeInterval = 0.35
    /// Spring damping for the intrinsic auto-resize: 1 = no overshoot, lower adds spring.
    /// Defaults to 0.9 for a smooth, non-snappy settle.
    public var intrinsicTransitionDampening: CGFloat = 0.9
    /// Allows dismissing of the sheet by pulling down
    public var dismissOnPull: Bool = true {
        didSet {
            self.updateAccessibility()
        }
    }
    /// Dismisses the sheet by tapping on the background overlay
    public var dismissOnOverlayTap: Bool = true {
       didSet {
           self.updateAccessibility()
       }
   }
    /// If true you can pull using UIControls (so you can grab and drag a button to control the sheet)
    public var shouldRecognizePanGestureWithUIControls: Bool = true

    /// When a registered child scroll view is scrolled to its top edge, whether continuing to pull
    /// up expands the sheet toward its largest detent (true, default) or lets the content scroll
    /// (false). Parity with `UISheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge`.
    public var scrollingExpandsWhenScrolledToEdge: Bool = true
    
    /// The view controller being presented by the sheet currently
    public var childViewController: UIViewController {
        return self.contentViewController.childViewController
    }

    public override var childForStatusBarStyle: UIViewController? {
        childViewController
    }
	
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return childViewController.supportedInterfaceOrientations
    }
    
    public static var hasBlurBackground = false
    public var hasBlurBackground = SheetViewController.hasBlurBackground {
        didSet {
            blurView.isHidden = !hasBlurBackground
            overlayView.backgroundColor = hasBlurBackground ? .clear : self.overlayColor
        }
    }
    
    public static var minimumSpaceAbovePullBar: CGFloat = 0
    public var minimumSpaceAbovePullBar: CGFloat {
        didSet {
            if self.isViewLoaded {
                self.resize(to: self.currentSize)
            }
        }
    }
    
    /// The default color of the overlay background
    public static var overlayColor = UIColor(white: 0, alpha: 0.25)
    /// The color of the overlay background
    public var overlayColor = SheetViewController.overlayColor {
        didSet {
            self.overlayView.backgroundColor = self.hasBlurBackground ? .clear : self.overlayColor
        }
    }
    
    public static var blurEffect: UIBlurEffect = {
        return UIBlurEffect(style: .prominent)
    }()
    
    public var blurEffect = SheetViewController.blurEffect {
        didSet {
            self.updateBlurEffect()
        }
    }

    /// Default value for useLiquidGlassBackground. Defaults to false.
    public static var useLiquidGlassBackground: Bool = false
    /// On iOS 26+, render the blur background with a Liquid Glass (`UIGlassEffect`) material instead
    /// of `blurEffect`. Has no effect below iOS 26, and defaults to false so the classic blur is
    /// preserved unless explicitly opted in.
    public var useLiquidGlassBackground = SheetViewController.useLiquidGlassBackground {
        didSet {
            self.updateBlurEffect()
        }
    }
    public static var allowGestureThroughOverlay: Bool = false
    public var allowGestureThroughOverlay: Bool = SheetViewController.allowGestureThroughOverlay {
        didSet {
            self.updateOverlayInteractivity()
            self.updateAccessibility()
        }
    }

    /// The largest detent at which the overlay is left undimmed and (in inline / `presentOverWindow`
    /// mode) lets touches pass through to the content behind — parity with
    /// `UISheetPresentationController.largestUndimmedDetentIdentifier`. `nil` (default) always dims.
    /// Note: under standard modal presentation the overlay undims but UIKit's presentation container
    /// still intercepts the touches (use `presentOverWindow` for real pass-through).
    public var largestUndimmedSize: SheetSize? {
        didSet {
            guard self.isViewLoaded else { return }
            self.overlayView.alpha = self.dimmedOverlayAlpha
            self.updateOverlayInteractivity()
            self.updateAccessibility()
        }
    }

    /// Target overlay dim alpha for the current detent (0 when it is within `largestUndimmedSize`).
    private var dimmedOverlayAlpha: CGFloat {
        guard let undimmed = self.largestUndimmedSize else { return 1 }
        return self.height(for: self.currentSize) <= self.height(for: undimmed) + 0.5 ? 0 : 1
    }

    /// Whether overlay-region touches should pass through (via `allowGestureThroughOverlay` or an
    /// undimmed detent).
    private var overlayPassesThrough: Bool {
        return self.allowGestureThroughOverlay || (self.largestUndimmedSize != nil && self.dimmedOverlayAlpha == 0)
    }

    private func updateOverlayInteractivity() {
        self.overlayTapView.isUserInteractionEnabled = !self.overlayPassesThrough
        if self.isViewLoaded {
            self.view.accessibilityViewIsModal = !self.overlayPassesThrough
        }
    }

    public static var cornerRadius: CGFloat = 12
    public var cornerRadius: CGFloat {
        get { return self.contentViewController.cornerRadius }
        set { self.contentViewController.cornerRadius = newValue }
    }

    public static var cornerCurve: CALayerCornerCurve = .circular

    public var cornerCurve: CALayerCornerCurve {
        get { return self.contentViewController.cornerCurve }
        set { self.contentViewController.cornerCurve = newValue }
    }
    
    public static var gripSize: CGSize = CGSize (width: 50, height: 6)
    public var gripSize: CGSize {
        get { return self.contentViewController.gripSize }
        set { self.contentViewController.gripSize = newValue }
    }
    
    public static var gripColor: UIColor = UIColor(white: 0.868, black: 0.5)
    public var gripColor: UIColor? {
        get { return self.contentViewController.gripColor }
        set { self.contentViewController.gripColor = newValue }
    }

    /// Default value for prefersGrabberVisible. Defaults to true.
    public static var prefersGrabberVisible: Bool = true
    /// Whether the grabber (grip) is shown on the pull bar. Defaults to true. (Parity with
    /// UISheetPresentationController.prefersGrabberVisible.) Requires a pull bar (pullBarHeight > 0).
    public var prefersGrabberVisible: Bool {
        get { return !self.contentViewController.isGripHidden }
        set { self.contentViewController.isGripHidden = !newValue }
    }
    
    public static var pullBarBackgroundColor: UIColor = UIColor.clear
    public var pullBarBackgroundColor: UIColor? {
        get { return self.contentViewController.pullBarBackgroundColor }
        set { self.contentViewController.pullBarBackgroundColor = newValue }
    }
    
    public static var treatPullBarAsClear: Bool = false
    public var treatPullBarAsClear: Bool {
        get { return self.contentViewController.treatPullBarAsClear }
        set { self.contentViewController.treatPullBarAsClear = newValue }
    }
    
    let transition: SheetTransition
    
    public var shouldDismiss: ((SheetViewController) -> Bool)?
    public var didDismiss: ((SheetViewController) -> Void)?
    public var sizeChanged: ((SheetViewController, SheetSize, CGFloat) -> Void)?
    /// Called continuously (roughly once per frame) while the sheet's content height is changing —
    /// during a drag AND during animated resizes/snaps — with a `SheetHeightProgress` the library
    /// computes from its own detents (live height, overall fraction, reached detent, and per-detent
    /// reveal). Unlike `sizeChanged` (which fires once per *settled* detent), this lets content
    /// interpolate its own animations progressively in lockstep with the sheet, and reacts the moment
    /// the height crosses a detent mid-drag. Fires on the main thread.
    public var progressChanged: ((SheetViewController, SheetHeightProgress) -> Void)?
    public var panGestureShouldBegin: ((UIPanGestureRecognizer) -> Bool?)?
    
    public private(set) var contentViewController: SheetContentViewController
    var overlayView = UIView()
    var blurView = UIVisualEffectView()
    var overlayTapView = UIView()
    var overlayTapGesture: UITapGestureRecognizer?
    private var contentViewHeightConstraint: NSLayoutConstraint!
    private var contentTopConstraint: NSLayoutConstraint?
    
    /// The child view controller's scroll view we are watching so we can override the pull down/up to work on the sheet when needed
    private weak var childScrollView: UIScrollView?
    
    private var keyboardHeight: CGFloat = 0
    private var firstPanPoint: CGPoint = CGPoint.zero
    private var panGestureRecognizer: InitialTouchPanGestureRecognizer!
    private var prePanHeight: CGFloat = 0
    /// The smallest detent's height as it was when the drag began.
    ///
    /// The pan clamps against this rather than re-reading `height(for: orderedSizes.first)` on every
    /// sample. Read live, an intrinsic height that changes mid-drag (content arriving from a network
    /// call, a row appearing) instantly moves both the clamped height and the pull-past-min offset —
    /// so the sheet jumps under a finger that has not moved. The release snap still uses the live
    /// height, so the gesture ends at the *current* detent; only the in-flight geometry is latched.
    private var prePanMinHeight: CGFloat = 0
    /// An intrinsic-height change that arrived while the sheet was moving.
    ///
    /// `preferredHeightChanged` cannot resize mid-gesture — it would fight the drag, and the release
    /// snap has already been aimed — so the correction is deferred to the moment the sheet settles
    /// rather than dropped. Dropped, the sheet stays at the height the snap was aimed at, which is no
    /// longer its intrinsic height, and nothing re-syncs it until the content happens to change again.
    private var hasPendingIntrinsicResize = false
    private var isPanning: Bool = false {
        didSet {
            // A drag (and the snap/dismiss/cancel animation that follows it, plus any re-grab) all
            // keep isPanning true until the sheet finally settles, so this is the one place to
            // begin/end progressive height tracking for the whole interaction.
            guard isPanning != oldValue else { return }
            if isPanning {
                self.beginHeightTracking()
            } else {
                self.endHeightTracking()
                self.flushPendingIntrinsicResize()
            }
        }
    }
    /// Drives the progressive `progressChanged` callback by sampling the presentation layer each frame
    /// while a drag or animated resize is in flight.
    private var heightDisplayLink: CADisplayLink?
    private var heightTrackingCount = 0
    private var lastReportedHeight: CGFloat = -1
    /// The in-flight detent snap animation, kept so a re-grab can interrupt it cleanly.
    private var snapAnimator: UIViewPropertyAnimator?
    /// The size the in-flight snap started from, so an interrupted snap can still report sizeChanged.
    private var snapPreviousSize: SheetSize?
    /// While a release snap animates, its destination height and travel direction. Used to clamp the
    /// reported progress height monotonically toward the target so the underdamped snap spring's
    /// overshoot/undershoot can't move `reachedIndex` past — or back across — the target detent
    /// boundary (the content correct→revert→correct flicker on release).
    private var snapTargetHeight: CGFloat?
    private var snapIsUp: Bool = false
    /// False until the sheet has finished its first appearance. While false, intrinsic-height
    /// corrections (the first measurement refining as real bounds/safe-area settle) are applied
    /// INSTANTLY so the sheet doesn't visibly resize just after it loads; genuine later content
    /// changes still glide with the spring.
    private var hasAppeared = false
    /// True while the sheet is attached over a window via `presentOverWindow(...)`; it reuses the
    /// subview-based lifecycle of inline mode without mutating the public `useInlineMode` option.
    private var isWindowAttached = false
    /// Whether the sheet manages its own view (inline option or window-attached) instead of being a UIKit modal.
    private var usesInlinePresentation: Bool { return self.options.useInlineMode || self.isWindowAttached }
    
    public var contentBackgroundColor: UIColor? {
        get { self.contentViewController.contentBackgroundColor }
        set { self.contentViewController.contentBackgroundColor = newValue }
    }
    
    public init(controller: UIViewController, sizes: [SheetSize] = [.intrinsic], options: SheetOptions? = nil) {
        let options = options ?? SheetOptions.default
        self.contentViewController = SheetContentViewController(childViewController: controller, options: options)
        self.contentViewController.contentBackgroundColor = UIColor.systemBackground
        self.sizes = sizes.count > 0 ? sizes : [.intrinsic]
        self.options = options
        self.transition = SheetTransition(options: options)
        self.minimumSpaceAbovePullBar = SheetViewController.minimumSpaceAbovePullBar
        super.init(nibName: nil, bundle: nil)
        self.gripColor = SheetViewController.gripColor
        self.gripSize = SheetViewController.gripSize
        self.prefersGrabberVisible = SheetViewController.prefersGrabberVisible
        self.pullBarBackgroundColor = SheetViewController.pullBarBackgroundColor
        self.cornerRadius = SheetViewController.cornerRadius
        self.updateOrderedSizes()
        self.modalPresentationStyle = .custom
        // .custom is a non-fullscreen style, so UIKit does not transfer status-bar control to
        // the presented VC by default; opt in so childForStatusBarStyle (and the child's
        // preferredStatusBarStyle) is actually consulted during modal presentation.
        self.modalPresentationCapturesStatusBarAppearance = true
        self.transitioningDelegate = self
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        // Use SheetView (which forwards point(inside:) so touches can pass through the overlay
        // region) in every mode. In modal presentation with the default
        // allowGestureThroughOverlay == false it behaves exactly like a plain UIView.
        let sheetView = SheetView()
        sheetView.delegate = self
        self.view = sheetView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.additionalSafeAreaInsets = UIEdgeInsets(top: -self.options.pullBarHeight, left: 0, bottom: 0, right: 0)
        
        self.view.backgroundColor = UIColor.clear
        self.addPanGestureRecognizer()
        self.addOverlay()
        self.addBlurBackground()
        self.addContentView()
        self.addOverlayTapView()
        // Keep VoiceOver inside the sheet (not the obscured presenter) unless pass-through is on.
        self.view.accessibilityViewIsModal = !self.overlayPassesThrough
        self.registerKeyboardObservers()
        self.resize(to: self.sizes.first ?? .intrinsic, animated: false)

        if self.allowGestureThroughOverlay && !self.usesInlinePresentation {
            print("FittedSheets: allowGestureThroughOverlay has no effect under standard modal presentation because UIKit's presentation container intercepts the touches. Present the sheet with presentOverWindow(...) instead.")
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        // viewIsAppearing runs with accurate bounds and trait collection (unlike viewWillAppear),
        // so the geometry-dependent sizing computes correct heights on first presentation.
        self.updateOrderedSizes()
        self.contentViewController.updatePreferredHeight()
        self.resize(to: self.currentSize, animated: false)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The child's final first-appearance re-measure is forwarded during super above (still
        // instant because hasAppeared is false); from here on, intrinsic changes animate.
        self.hasAppeared = true
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard self.isViewLoaded else { return }
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self, let constraint = self.contentViewHeightConstraint else { return }
            // self.view.bounds is already the post-rotation size here, so height(for:) is correct.
            self.updateOrderedSizes()
            constraint.constant = self.height(for: self.currentSize)
            self.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            // Width changed -> intrinsic content height may differ; re-measure and settle.
            self.contentViewController.updatePreferredHeight()
            self.updateOrderedSizes()
            self.resize(to: self.currentSize, animated: false)
            // resize(animated:false) early-returns when the constant is unchanged (it was already set
            // to the new post-rotation height above), so push the new geometry to progressChanged
            // explicitly — otherwise consumers keep the pre-rotation progress until the next drag.
            self.reportHeightIfChanged()
        })
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Only run dismissal side-effects on a real dismissal, not when the sheet
        // itself presents a .fullScreen modal (which also triggers viewDidDisappear).
        guard self.isBeingDismissed || self.presentingViewController == nil else { return }
        // Safety net: the CADisplayLink retains self, so make sure it is gone on dismissal even if
        // a tracking source didn't balance (it normally ends via isPanning / the resize completion).
        self.tearDownHeightTracking()
        // Reset so a reused sheet re-applies its first-appearance intrinsic refinement instantly.
        self.hasAppeared = false
        // Balance the static presenter cache regardless of the shrink option so a
        // non-animated dismissal (e.g. pull-to-dismiss) can never leak the presenter.
        if let presenter = self.transition.presenter, SheetOptions.shrinkingNestedPresentingViewControllers {
            SheetTransition.currentPresenters.removeAll(where: { $0 == presenter })
        }
        if let presenter = self.transition.presenter, self.options.shrinkPresentingViewController {
            self.transition.restorePresentor(presenter, completion: { _ in
                self.didDismiss?(self)
            })
        } else if !self.usesInlinePresentation {
            self.didDismiss?(self)
        }
    }
    
    /// Handle a scroll view in the child view controller by watching for the offset for the scrollview and taking priority when at the top (so pulling up/down can grow/shrink the sheet instead of bouncing the child's scroll view)
    public func handleScrollView(_ scrollView: UIScrollView) {
        scrollView.panGestureRecognizer.require(toFail: panGestureRecognizer)
        self.childScrollView = scrollView
    }
    
    /// Change the sizes the sheet should try to pin to
    public func setSizes(_ sizes: [SheetSize], animated: Bool = true) {
        guard sizes.count > 0 else {
            return
        }
        self.sizes = sizes
        
        self.resize(to: sizes[0], animated: animated)
    }
    
    func updateOrderedSizes() {
        var concreteSizes: [(SheetSize, CGFloat)] = self.sizes.map {
            return ($0, self.height(for: $0))
        }
        concreteSizes.sort { $0.1 < $1.1 }
        self.orderedSizes = concreteSizes.map({ size, _ in size })
        self.updateAccessibility()
    }
    
    private func updateAccessibility() {
        let isOverlayAccessable = !self.overlayPassesThrough && (self.dismissOnOverlayTap || self.dismissOnPull)
        self.overlayTapView.isAccessibilityElement = isOverlayAccessable
        
        var pullBarLabel = ""
        if !isOverlayAccessable && (self.dismissOnOverlayTap || self.dismissOnPull) {
            pullBarLabel = Localize.dismissPresentation.localized
        } else if self.orderedSizes.count > 1 {
            pullBarLabel = Localize.changeSizeOfPresentation.localized
        }
        
        self.contentViewController.pullBarView.isAccessibilityElement = !pullBarLabel.isEmpty
        self.contentViewController.pullBarView.accessibilityLabel = pullBarLabel
    }
    
    private func addOverlay() {
        self.view.addSubview(self.overlayView)
        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.overlayView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.overlayView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.overlayView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.overlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.overlayView.isUserInteractionEnabled = false
        self.overlayView.backgroundColor = self.hasBlurBackground ? .clear : self.overlayColor
    }

    private func addBlurBackground() {
        self.overlayView.addSubview(self.blurView)
        self.updateBlurEffect()
        self.blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.blurView.topAnchor.constraint(equalTo: self.overlayView.topAnchor),
            self.blurView.leftAnchor.constraint(equalTo: self.overlayView.leftAnchor),
            self.blurView.rightAnchor.constraint(equalTo: self.overlayView.rightAnchor),
            self.blurView.bottomAnchor.constraint(equalTo: self.overlayView.bottomAnchor)
        ])
        self.blurView.isUserInteractionEnabled = false
        self.blurView.isHidden = !self.hasBlurBackground
    }

    private func updateBlurEffect() {
        if #available(iOS 26.0, *), self.useLiquidGlassBackground {
            self.blurView.effect = UIGlassEffect()
        } else {
            self.blurView.effect = self.blurEffect
        }
    }
    
    private func addOverlayTapView() {
        let overlayTapView = self.overlayTapView
        overlayTapView.backgroundColor = .clear
        overlayTapView.isUserInteractionEnabled = !self.overlayPassesThrough
        self.view.addSubview(overlayTapView)
        self.overlayTapView.accessibilityLabel = Localize.dismissPresentation.localized
        overlayTapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayTapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            overlayTapView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            overlayTapView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            overlayTapView.bottomAnchor.constraint(equalTo: self.contentViewController.view.topAnchor)
        ])
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        self.overlayTapGesture = tapGestureRecognizer
        overlayTapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func overlayTapped(_ gesture: UITapGestureRecognizer) {
        // A VoiceOver activation of the overlay element we labeled "Dismiss presentation"
        // should honor dismissOnPull too; a real (sighted) overlay tap must still respect
        // dismissOnOverlayTap only.
        guard self.dismissOnOverlayTap
            || (UIAccessibility.isVoiceOverRunning && self.dismissOnPull) else { return }
        self.attemptDismiss(animated: true)
    }

    /// Standard VoiceOver two-finger "scrub" to dismiss.
    public override func accessibilityPerformEscape() -> Bool {
        guard self.dismissOnPull || self.dismissOnOverlayTap else { return false }
        self.attemptDismiss(animated: true)
        return true
    }

    private func addContentView() {
        self.addChild(self.contentViewController)
        self.view.addSubview(self.contentViewController.view)
        self.contentViewController.didMove(toParent: self)
        self.contentViewController.delegate = self
        let contentView = self.contentViewController.view!
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Prefer pinning to the left edge, but only softly so centerX/maxWidth can win.
        let leftPreferred = contentView.leftAnchor.constraint(equalTo: self.view.leftAnchor)
        leftPreferred.priority = UILayoutPriority(999)

        let heightConstraint = contentView.heightAnchor.constraint(equalToConstant: self.height(for: self.currentSize))
        self.contentViewHeightConstraint = heightConstraint

        // self.view.window is nil during viewDidLoad, so seed a safe fallback and apply
        // the real (scene-correct) inset later in viewSafeAreaInsetsDidChange.
        let top: CGFloat = self.options.useFullScreenMode ? 0 : 12
        let topConstraint = contentView.topAnchor.constraint(greaterThanOrEqualTo: self.view.topAnchor, constant: top)
        topConstraint.priority = UILayoutPriority(999)
        self.contentTopConstraint = topConstraint

        var constraints: [NSLayoutConstraint] = [
            leftPreferred,
            contentView.leftAnchor.constraint(greaterThanOrEqualTo: self.view.leftAnchor, constant: self.options.horizontalPadding),
            contentView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            heightConstraint,
            contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            topConstraint
        ]
        if let maxWidth = self.options.maxWidth {
            constraints.append(contentView.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth))
        }
        NSLayoutConstraint.activate(constraints)
    }

    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        guard !self.options.useFullScreenMode else { return }
        // Scene-correct + extension-safe: use the sheet's own window, not the deprecated
        // UIApplication.shared.windows key-window scan.
        let windowTop = self.view.window?.safeAreaInsets.top ?? 0
        self.contentTopConstraint?.constant = max(12, windowTop)
    }
    
    private func addPanGestureRecognizer() {
        let panGestureRecognizer = InitialTouchPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        self.panGestureRecognizer = panGestureRecognizer
    }
    
    @objc func panned(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.translation(in: gesture.view?.superview)
        if gesture.state == .began {
            self.firstPanPoint = point
            let contentView = self.contentViewController.view!
            // If a snap animation is still in flight, its model-layer bounds already hold the
            // FINAL height while only the presentation layer is mid-transition. Read the height
            // actually on screen, cancel the animator, and sync the constraint so the sheet does
            // not jump under the finger on re-grab.
            if let animator = self.snapAnimator, animator.isRunning {
                let presentedHeight = contentView.layer.presentation()?.bounds.height ?? contentView.bounds.height
                animator.stopAnimation(true)
                self.snapAnimator = nil
                self.snapTargetHeight = nil
                contentView.transform = .identity
                self.contentViewHeightConstraint.constant = max(0, presentedHeight)
                self.view.layoutIfNeeded()
                self.prePanHeight = presentedHeight
                // stopAnimation(true) skips the animator's completion, so fire the interrupted
                // snap's pending sizeChanged here (currentSize was already advanced to the target).
                if let prev = self.snapPreviousSize, prev != self.currentSize {
                    self.sizeChanged?(self, self.currentSize, self.height(for: self.currentSize))
                }
                self.snapPreviousSize = nil
            } else {
                self.prePanHeight = contentView.bounds.height
            }
            self.prePanMinHeight = self.height(for: self.orderedSizes.first)
            self.isPanning = true
        }

        // Latched at `.began`, not re-read per sample — see `prePanMinHeight`. Falls back to the live
        // value for a stray `.changed` that never saw a `.began`.
        let minHeight: CGFloat = self.isPanning ? self.prePanMinHeight : self.height(for: self.orderedSizes.first)
        let maxHeight: CGFloat
        if self.allowPullingPastMaxHeight {
            maxHeight = self.height(for: .fullscreen) // self.view.bounds.height
        } else {
            maxHeight = max(self.height(for: self.orderedSizes.last), self.prePanHeight)
        }
        
        var newHeight = max(0, self.prePanHeight + (self.firstPanPoint.y - point.y))
        var offset: CGFloat = 0
        if newHeight < minHeight {
            if self.allowPullingPastMinHeight {
                offset = minHeight - newHeight
            }
            newHeight = minHeight
        }
        if newHeight > maxHeight {
            if options.isRubberBandEnabled {
                newHeight = logConstraintValueForYPosition(verticalLimit: maxHeight, yPosition: newHeight)
            } else {
                newHeight = maxHeight
            }
        }
        
        switch gesture.state {
            case .cancelled, .failed:
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                    self.contentViewController.view.transform = CGAffineTransform.identity
                    self.contentViewHeightConstraint.constant = self.height(for: self.currentSize)
                    self.transition.setPresentor(percentComplete: 0)
                    self.overlayView.alpha = self.dimmedOverlayAlpha
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    self.isPanning = false
                })
            
            case .began, .changed:
                self.contentViewHeightConstraint.constant = newHeight
                
                if offset > 0 {
                    let percent = max(0, min(1, offset / max(1, newHeight)))
                    self.transition.setPresentor(percentComplete: percent)
                    self.overlayView.alpha = 1 - percent
                    self.contentViewController.view.transform = CGAffineTransform(translationX: 0, y: offset)
                } else {
                    self.contentViewController.view.transform = CGAffineTransform.identity
                }
            case .ended:
                let velocity = (0.2 * gesture.velocity(in: self.view).y)
                var finalHeight = newHeight - offset - velocity
                if velocity > options.pullDismissThreshold {
                    // They swiped hard, always just close the sheet when they do
                    finalHeight = -1
                }
                
                let animationDuration = TimeInterval(abs(velocity*0.0002) + 0.1)
                
                guard finalHeight > 0 || !(self.dismissOnPull && self.shouldDismiss?(self) ?? true) else {
                    // Dismiss
                    UIView.animate(
                        withDuration: animationDuration,
                        delay: 0,
                        usingSpringWithDamping: self.options.transitionDampening,
                        initialSpringVelocity: self.options.transitionVelocity,
                        options: self.options.transitionAnimationOptions,
                        animations: {
                        self.contentViewController.view.transform = CGAffineTransform(translationX: 0, y: self.contentViewController.view.bounds.height)
                        self.view.backgroundColor = UIColor.clear
                        self.transition.setPresentor(percentComplete: 1)
                        self.overlayView.alpha = 0
                    }, completion: { complete in
                        // Leaving: a deferred intrinsic correction has nothing left to correct.
                        self.hasPendingIntrinsicResize = false
                        self.isPanning = false
                        self.performDismiss(animated: false)   // shouldDismiss already evaluated in the guard above
                    })
                    return
                }
                
                // `finalHeight` already accounts for release velocity (newHeight - offset - velocity),
                // so snapping it to the nearest detent gives velocity-aware behavior *and* hysteresis:
                // a tiny drag stays next to the current detent, while a hard flick reaches a neighbor.
                var newSize = self.currentSize
                if !self.orderedSizes.isEmpty {
                    newSize = self.orderedSizes.min(by: {
                        abs(self.height(for: $0) - finalHeight) < abs(self.height(for: $1) - finalHeight)
                    }) ?? self.currentSize
                }
                let previousSize = self.currentSize
                self.currentSize = newSize
                
                let newContentHeight = self.height(for: newSize)
                // Interruptible spring snap: a UIViewPropertyAnimator lets a re-grab (handled in
                // the .began branch) stop it mid-flight and continue from the on-screen position.
                self.snapPreviousSize = previousSize
                let damping = max(0.1, min(1.0, self.options.transitionDampening))
                let releaseHeight = self.contentViewHeightConstraint?.constant ?? newHeight
                let isUp = newContentHeight >= releaseHeight
                let snapsToMax = newContentHeight >= self.height(for: .fullscreen) - 0.5
                let snapsToMin = newContentHeight <= self.height(for: self.orderedSizes.first) + 0.5
                let timing: UITimingCurveProvider
                let snapDuration: TimeInterval
                if (isUp && snapsToMax) || (!isUp && snapsToMin) {
                    // No overshoot when snapping to an extreme detent — a spring is wrong at both ends:
                    //  • Up to the max: underdamped it overshoots past the top of the screen and bounces;
                    //    critically damped it eases in slowly so the sheet hangs at the dragged position
                    //    before rising ("pulled down, then springs back up").
                    //  • Down to the min: it overshoots *shorter* than the content can fit, breaking the
                    //    collapsed layout — which also re-measures the intrinsic height and fires a
                    //    competing resize, so the collapse reads as a jerk.
                    // A decelerating ease-out starts moving immediately and settles cleanly at the
                    // detent from either direction; mid-detent snaps keep the springy feel.
                    timing = UICubicTimingParameters(animationCurve: .easeOut)
                    snapDuration = max(0.14, animationDuration * 0.6)
                } else {
                    timing = UISpringTimingParameters(dampingRatio: damping, initialVelocity: CGVector(dx: 0, dy: self.options.transitionVelocity))
                    snapDuration = animationDuration
                }
                let animator = UIViewPropertyAnimator(duration: snapDuration, timingParameters: timing)
                self.snapTargetHeight = newContentHeight
                self.snapIsUp = isUp
                self.contentViewHeightConstraint.constant = newContentHeight
                animator.addAnimations { [weak self] in
                    guard let self = self else { return }
                    self.contentViewController.view.transform = CGAffineTransform.identity
                    self.transition.setPresentor(percentComplete: 0)
                    self.overlayView.alpha = self.dimmedOverlayAlpha
                    self.view.layoutIfNeeded()
                }
                animator.addCompletion { [weak self] _ in
                    guard let self = self else { return }
                    self.snapAnimator = nil
                    self.snapPreviousSize = nil
                    self.snapTargetHeight = nil
                    self.isPanning = false
                    // The detent may have crossed the largestUndimmedSize threshold, so re-derive
                    // overlay interactivity/accessibility from the new size (matching resize()).
                    self.updateOverlayInteractivity()
                    self.updateAccessibility()
                    if previousSize != newSize {
                        self.sizeChanged?(self, newSize, newContentHeight)
                    }
                }
                self.snapAnimator = animator
                animator.startAnimation()
            case .possible:
                break
            @unknown default:
                break // Do nothing
        }
    }

    // MARK: - Progressive height tracking

    /// Start sampling the on-screen height each frame. Ref-counted so overlapping sources (a drag
    /// and an animated resize) both keep it alive; a no-op when no `progressChanged` observer is set.
    private func beginHeightTracking() {
        guard self.progressChanged != nil else { return }
        self.heightTrackingCount += 1
        guard self.heightDisplayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(self.heightTrackingTick))
        link.add(to: .main, forMode: .common)
        self.heightDisplayLink = link
    }

    private func endHeightTracking() {
        guard self.heightDisplayLink != nil else { return }
        self.heightTrackingCount = max(0, self.heightTrackingCount - 1)
        guard self.heightTrackingCount == 0 else { return }
        self.heightDisplayLink?.invalidate()
        self.heightDisplayLink = nil
        self.reportHeightIfChanged() // deliver the final settled height
    }

    @objc private func heightTrackingTick() {
        self.reportHeightIfChanged()
    }

    /// Forward the current content height if it moved since the last report. Reads the interpolated
    /// presentation layer only while an animation is in flight (display link active); for one-shot
    /// and settled reports it reads the model height, since the presentation layer still holds the
    /// pre-layout on-screen value at the synchronous moment we sample it.
    private func reportHeightIfChanged() {
        guard let onChanged = self.progressChanged, let contentView = self.contentViewController.viewIfLoaded else { return }
        let height: CGFloat
        if self.heightDisplayLink != nil, let presented = contentView.layer.presentation()?.bounds.height {
            if let target = self.snapTargetHeight {
                // During a release snap the sheet's spring overshoots/undershoots the target detent.
                // Pin the *reported* height monotonically to the target (using lastReportedHeight as
                // the accumulator) so the content settles on the target detent once and can't flip
                // back across it. The sheet's physical spring motion is unaffected.
                height = self.snapIsUp
                    ? min(target, max(self.lastReportedHeight, presented))
                    : max(target, min(self.lastReportedHeight, presented))
            } else {
                // Mid-animation (drag / non-snap resize): the interpolated on-screen height.
                height = presented
            }
        } else {
            // Settled / one-shot: the height constraint's constant is the reliable target (the
            // content view's own bounds can still be stale here, as its frame is resolved by its
            // superview's layout pass which hasn't run yet).
            height = self.contentViewHeightConstraint?.constant ?? contentView.bounds.height
        }
        guard abs(height - self.lastReportedHeight) >= 0.1 else { return }
        self.lastReportedHeight = height
        onChanged(self, self.makeProgress(height: height))
    }

    /// Compute the live progress across the sheet's defined detents. The library owns this math so
    /// content never needs to know the detent heights.
    private func makeProgress(height: CGFloat) -> SheetHeightProgress {
        let sizeList = self.orderedSizes.isEmpty ? self.sizes : self.orderedSizes
        // (size, height) sorted smallest → largest.
        let ordered = sizeList.map { ($0, self.height(for: $0)) }.sorted { $0.1 < $1.1 }
        guard let smallest = ordered.first, let largest = ordered.last else {
            let step = SheetHeightProgress.Step(size: self.currentSize, height: height, reveal: 1)
            return SheetHeightProgress(height: height, fraction: 0, reachedSize: self.currentSize, reachedIndex: 0, steps: [step])
        }

        let steps: [SheetHeightProgress.Step] = ordered.enumerated().map { index, entry in
            let reveal: CGFloat
            if index == 0 {
                reveal = 1
            } else {
                let lower = ordered[index - 1].1
                let span = entry.1 - lower
                reveal = span > 0 ? min(1, max(0, (height - lower) / span)) : (height >= entry.1 ? 1 : 0)
            }
            return SheetHeightProgress.Step(size: entry.0, height: entry.1, reveal: reveal)
        }

        // Reached = the highest fully-revealed detent, derived from the same boundary as `reveal` so
        // `reachedIndex`/`reachedSize` and `steps[i].reveal` can never disagree. Step 0 is always
        // revealed, so this is at least 0.
        var reachedIndex = 0
        for (index, step) in steps.enumerated() where step.reveal >= 1 { reachedIndex = index }

        let fullSpan = largest.1 - smallest.1
        let fraction = fullSpan > 0 ? min(1, max(0, (height - smallest.1) / fullSpan)) : 0
        return SheetHeightProgress(height: height, fraction: fraction, reachedSize: ordered[reachedIndex].0, reachedIndex: reachedIndex, steps: steps)
    }

    /// The sheet's current progress across its detents — the same value delivered to
    /// `progressChanged`. Use it to seed content state before the first callback arrives.
    public var currentProgress: SheetHeightProgress {
        let height = self.contentViewHeightConstraint?.constant
            ?? self.contentViewController.viewIfLoaded?.bounds.height
            ?? 0
        return self.makeProgress(height: height)
    }

    /// Applies an intrinsic-height change that arrived while the sheet was moving, now that it has
    /// settled. Runs from `isPanning`'s transition to false — the one point every ending funnels
    /// through (release snap, cancelled gesture, interrupted re-grab).
    private func flushPendingIntrinsicResize() {
        guard self.hasPendingIntrinsicResize else { return }
        self.hasPendingIntrinsicResize = false
        // Not while leaving: a sheet being dismissed (or already detached) must not animate back to
        // a detent on its way out.
        guard self.currentSize == .intrinsic, self.isViewLoaded, self.view.window != nil,
              !self.isBeingDismissed else { return }
        self.resize(to: .intrinsic,
                    duration: self.intrinsicTransitionDuration,
                    options: [.beginFromCurrentState],
                    dampingRatio: self.intrinsicTransitionDampening)
    }

    private func tearDownHeightTracking() {
        self.heightDisplayLink?.invalidate()
        self.heightDisplayLink = nil
        self.heightTrackingCount = 0
        // Reset so a reused sheet re-reports its first height on the next presentation.
        self.lastReportedHeight = -1
    }

    private func registerKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDismissed(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardShown(_ notification: Notification) {
        guard let info:[AnyHashable: Any] = notification.userInfo,
              let keyboardRect:CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        // Ignore keyboards while our view is not in a window (detached / covered by a full-screen modal).
        guard self.view.window != nil else { return }
        // Ignore keyboards belonging to another app in iPad multitasking.
        if let isLocal = info[UIResponder.keyboardIsLocalUserInfoKey] as? Bool, isLocal == false { return }

        // Convert the keyboard frame from screen space into our view and take the real overlap;
        // the previous window-vs-screen subtraction was wrong (and could go negative) whenever the
        // window was offset from the screen origin (Split View / Stage Manager / inline mode).
        let screenSpace: UICoordinateSpace? = self.view.window?.screen.coordinateSpace
        let keyboardInView = screenSpace.map { self.view.convert(keyboardRect, from: $0) } ?? keyboardRect
        let overlap = self.view.bounds.intersection(keyboardInView)
        let actualHeight = overlap.isNull ? 0 : max(0, overlap.height)
        self.adjustForKeyboard(height: actualHeight, from: notification)
    }
    
    @objc func keyboardDismissed(_ notification: Notification) {
        self.adjustForKeyboard(height: 0, from: notification)
    }
    
    private func adjustForKeyboard(height: CGFloat, from notification: Notification) {
        // Even when keyboard avoidance is disabled, clear an inset a prior keyboard left applied
        // (e.g. autoAdjustToKeyboard was toggled off while the keyboard was up, or a shrinking
        // frame was missed while the sheet was off-window). Otherwise height(for: .intrinsic) keeps
        // adding a stale keyboardHeight and the sheet stays permanently oversized. Scoped to a real
        // pending inset so a deliberately-disabled sheet is left untouched.
        if height == 0, !self.autoAdjustToKeyboard, self.keyboardHeight != 0 {
            self.keyboardHeight = 0
            self.contentViewController.adjustForKeyboard(height: 0)
            self.resize(to: self.currentSize, animated: false)
        }
        guard self.autoAdjustToKeyboard, let info:[AnyHashable: Any] = notification.userInfo else { return }
        self.keyboardHeight = height
        
        let duration:TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw << 16)
        
        self.contentViewController.adjustForKeyboard(height: self.keyboardHeight)
        self.resize(to: self.currentSize, duration: duration, options: animationCurve, animated: true, complete: {
            self.resize(to: self.currentSize)
        })
    }
    
    private func height(for size: SheetSize?) -> CGFloat {
        guard let size = size else { return 0 }
        let contentHeight: CGFloat
        let fullscreenHeight: CGFloat
        // Avoid forcing a view load (and the child's viewDidLoad) if callers query sizes
        // before presentation; fall back to the key window / screen bounds when unloaded.
        let bounds: CGRect
        let safeAreaTop: CGFloat
        if self.isViewLoaded {
            bounds = self.view.bounds
            safeAreaTop = self.view.safeAreaInsets.top
        } else {
            let keyWindow = UIApplication.shared.fs_keyWindow
            bounds = keyWindow?.bounds ?? UIScreen.main.bounds
            safeAreaTop = keyWindow?.safeAreaInsets.top ?? 0
        }
        if self.options.useFullScreenMode {
            fullscreenHeight = bounds.height - self.minimumSpaceAbovePullBar
        } else {
            fullscreenHeight = bounds.height - safeAreaTop - self.minimumSpaceAbovePullBar
        }
        switch (size) {
            case .fixed(let height):
                contentHeight = height + self.keyboardHeight
            case .fullscreen:
                contentHeight = fullscreenHeight
            case .intrinsic:
                contentHeight = self.contentViewController.preferredHeight + self.keyboardHeight
            case .percent(let percent):
                if (percent > 1) {
                    debugPrint("Size percent should be less than or equal to 1.0, but was set to \(percent))")
                }
                contentHeight = bounds.height * percent + self.keyboardHeight
            case .marginFromTop(let margin):
                contentHeight = bounds.height - margin + self.keyboardHeight
        }
        return max(0, min(fullscreenHeight, contentHeight))
    }

    // https://medium.com/thoughts-on-thoughts/recreating-apple-s-rubber-band-effect-in-swift-dbf981b40f35
    private func logConstraintValueForYPosition(verticalLimit: CGFloat, yPosition : CGFloat) -> CGFloat {
      guard verticalLimit > 0 else { return verticalLimit }
      return verticalLimit * (1 + log10(yPosition/verticalLimit))
    }
    
    public func resize(to size: SheetSize,
                       duration: TimeInterval = 0.2,
                       options: UIView.AnimationOptions = [.curveEaseOut],
                       animated: Bool = true,
                       dampingRatio: CGFloat? = nil,
                       initialVelocity: CGFloat = 0,
                       complete: (() -> Void)? = nil) {

        let previousSize = self.currentSize
        self.currentSize = size

        let oldConstraintHeight = self.contentViewHeightConstraint.constant

        let newHeight = self.height(for: size)

        guard oldConstraintHeight != newHeight else {
            // Height unchanged, but the logical size may have; still honor the callback contract.
            if previousSize != size, newHeight > 0 {
                self.sizeChanged?(self, size, newHeight)
            }
            complete?()
            return
        }

        if animated {
            let animations = { [weak self] in
                guard let self = self, let constraint = self.contentViewHeightConstraint else { return }
                constraint.constant = newHeight
                self.overlayView.alpha = self.dimmedOverlayAlpha
                self.view.layoutIfNeeded()
            }
            let completion: (Bool) -> Void = { _ in
                self.endHeightTracking()
                self.updateOverlayInteractivity()
                if previousSize != size, newHeight > 0 {
                    self.sizeChanged?(self, size, newHeight)
                }
                complete?()
            }
            // Sample the presentation layer each frame so `progressChanged` fires progressively as
            // the constraint animates, not just once at the end.
            self.beginHeightTracking()
            // A spring settle (dampingRatio set) reads as smooth rather than snappy; used for the
            // intrinsic auto-resize. Everything else keeps the timing-curve animation.
            if let dampingRatio = dampingRatio {
                UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: dampingRatio, initialSpringVelocity: initialVelocity, options: options, animations: animations, completion: completion)
            } else {
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: completion)
            }
        } else {
            UIView.performWithoutAnimation {
                self.contentViewHeightConstraint?.constant = newHeight
                self.overlayView.alpha = self.dimmedOverlayAlpha
                self.contentViewController.view.layoutIfNeeded()
            }
            self.updateOverlayInteractivity()
            self.reportHeightIfChanged()
            if previousSize != size, newHeight > 0 {
                self.sizeChanged?(self, size, newHeight)
            }
            complete?()
        }
    }
    
    public func attemptDismiss(animated: Bool) {
        if self.shouldDismiss?(self) != false {
            self.performDismiss(animated: animated)
        }
    }

    /// Performs the dismissal without re-consulting `shouldDismiss` (the caller is responsible
    /// for having evaluated it exactly once).
    private func performDismiss(animated: Bool) {
        if self.usesInlinePresentation {
            if animated {
                self.animateOut {
                    self.didDismiss?(self)
                }
            } else {
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
                self.isWindowAttached = false
                self.didDismiss?(self)
            }
        } else {
            self.dismiss(animated: animated, completion: nil)
        }
    }
    
    /// Recalculates the intrinsic height of the sheet based on the content, and updates the sheet height to match.
    ///
    /// **Note:** Only meant for use with the `.intrinsic` sheet size.
    ///
    /// The sheet re-measures automatically on appearance, rotation, Dynamic Type changes, and
    /// navigation push/pop. It does **not** observe arbitrary content growth, so call this after
    /// changes it can't detect, e.g.:
    /// - the child's content grows after an async load, a `reloadData()`, or a late text/`isHidden` change;
    /// - you toggle the child navigation bar's visibility or translucency on the *current* top view
    ///   controller (no `willShow`/`didShow` fires, so the reserved bar height goes stale).
    ///
    /// Also note: `.intrinsic` children should pin bottom content to `safeAreaLayoutGuide.bottomAnchor`.
    /// The card's bottom sits at the screen bottom, so content pinned to the raw `bottomAnchor` will
    /// underlap the home indicator — the sheet reserves the bottom safe area only for children that
    /// respect it.
    public func updateIntrinsicHeight() {
        contentViewController.updatePreferredHeight()
    }
    
    /// Animates the sheet in, but only if presenting using the inline mode
    /// Presents the sheet attached over the app's key window instead of as a UIKit modal.
    ///
    /// Use this (rather than `UIViewController.present(_:animated:)`) when `allowGestureThroughOverlay`
    /// is set: a standard modal cannot pass touches through, because UIKit's presentation container
    /// view intercepts them. A window-attached sheet instead sits as a sibling over the current
    /// content, so `SheetView.point(inside:)` can forward overlay-region touches straight through to
    /// the app behind. Dismissal (overlay tap, pull-down, `attemptDismiss`) works as in inline mode.
    ///
    /// - Returns: `false` if no key window / root view controller could be found.
    @discardableResult
    public func presentOverWindow(_ window: UIWindow? = nil, size: SheetSize? = nil, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) -> Bool {
        guard let hostWindow = window ?? UIApplication.shared.fs_keyWindow,
              let root = hostWindow.rootViewController else {
            print("FittedSheets: presentOverWindow could not find a key window with a root view controller.")
            return false
        }
        let parent = SheetViewController.topPresentedViewController(from: root)
        // Route through the inline/window-attach machinery so overlay touches can pass through and
        // dismissal uses the subview-removal path rather than UIKit modal dismissal. Use a private
        // flag rather than mutating the public useInlineMode so the instance stays reusable.
        self.isWindowAttached = true
        self.animateIn(to: parent.view, in: parent, size: size, duration: duration, completion: completion)
        return true
    }

    private static func topPresentedViewController(from vc: UIViewController) -> UIViewController {
        var top = vc
        while let presented = top.presentedViewController, !presented.isBeingDismissed {
            top = presented
        }
        return top
    }

    public func animateIn(to view: UIView, in parent: UIViewController, size: SheetSize? = nil, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        guard self.usesInlinePresentation else {
            assertionFailure("animateIn(to:in:) requires SheetOptions.useInlineMode == true; use present(_:animated:) for modal presentation.")
            completion?()
            return
        }

        parent.addChild(self)
        view.addSubview(self.view)
        self.didMove(toParent: parent)
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.view.topAnchor.constraint(equalTo: view.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        self.animateIn(size: size, duration: duration, completion: completion)
    }
    
    public func animateIn(size: SheetSize? = nil, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        guard self.usesInlinePresentation else { completion?(); return }
        guard self.view.superview != nil else {
            print("It appears your sheet is not set as a subview of another view. Make sure to add this view as a subview before trying to animate it in.")
            completion?()
            return
        }
        self.view.superview?.layoutIfNeeded()
        self.contentViewController.updatePreferredHeight()
        self.resize(to: size ?? self.sizes.first ?? self.currentSize, animated: false)
        let contentView = self.contentViewController.view!
        contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.height)
        self.overlayView.alpha = 0
        self.updateOrderedSizes()
        
        UIView.animate(
            withDuration: duration,
            animations: {
                contentView.transform = .identity
                self.overlayView.alpha = self.dimmedOverlayAlpha
            },
            completion: { _ in
                self.hasAppeared = true
                completion?()
            }
        )
    }
    
    /// Animates the sheet out, but only if presenting using the inline mode
    public func animateOut(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        guard self.usesInlinePresentation else { completion?(); return }
        let contentView = self.contentViewController.view!
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: self.options.transitionDampening,
            initialSpringVelocity: self.options.transitionVelocity,
            options: self.options.transitionAnimationOptions,
            animations: {
                contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.height)
                self.overlayView.alpha = 0
            },
            completion: { _ in
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
                self.isWindowAttached = false
                self.hasAppeared = false
                completion?()
            }
        )
    }
}

// MARK: - Async / await presentation

extension SheetViewController {
    /// Presents the sheet modally from `presenter` and returns once the entry animation completes.
    public func present(from presenter: UIViewController, animated: Bool = true) async {
        await withCheckedContinuation { continuation in
            presenter.present(self, animated: animated) {
                continuation.resume()
            }
        }
    }

    /// Window-attach presentation (see `presentOverWindow`) that returns once the entry animation
    /// completes. Returns `false` if no key window with a root view controller could be found.
    @discardableResult
    public func presentOverWindow(_ window: UIWindow? = nil, size: SheetSize? = nil, duration: TimeInterval = 0.3) async -> Bool {
        await withCheckedContinuation { continuation in
            let started = self.presentOverWindow(window, size: size, duration: duration) {
                continuation.resume(returning: true)
            }
            if !started {
                continuation.resume(returning: false)
            }
        }
    }

    /// Inline/window-attach animate-in that returns once the animation completes.
    public func animateIn(to view: UIView, in parent: UIViewController, size: SheetSize? = nil, duration: TimeInterval = 0.3) async {
        await withCheckedContinuation { continuation in
            self.animateIn(to: view, in: parent, size: size, duration: duration) {
                continuation.resume()
            }
        }
    }

    /// Inline/window-attach animate-out that returns once the animation completes.
    public func animateOut(duration: TimeInterval = 0.3) async {
        await withCheckedContinuation { continuation in
            self.animateOut(duration: duration) {
                continuation.resume()
            }
        }
    }
}

extension SheetViewController: SheetViewDelegate {
    func sheetPoint(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard self.overlayPassesThrough else { return true }
        // Keep only touches on the sheet content card; let everything else (the dimmed overlay,
        // including the side gutters when maxWidth/horizontalPadding narrows the card) pass through.
        // `point` and the content frame are both in this view's coordinate space.
        let isOverContent = self.contentViewController.view.frame.contains(point)
        if !isOverContent {
            return false
        } else {
            return true
        }
    }
}

extension SheetViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Allowing gesture recognition on a UIControl seems to prevent its events from firing properly sometimes
        if !shouldRecognizePanGestureWithUIControls {
            if let view = touch.view {
                return !(view is UIControl)
            }
        }
        return true
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Consult the public closure first so it works even without a registered child scroll view.
        if let pan = gestureRecognizer as? UIPanGestureRecognizer, let closure = panGestureShouldBegin, let should = closure(pan) {
            return should
        }

        guard let panGestureRecognizer = gestureRecognizer as? InitialTouchPanGestureRecognizer, let childScrollView = self.childScrollView, let point = panGestureRecognizer.initialTouchLocation else { return true }

        let pointInChildScrollView = self.view.convert(point, to: childScrollView).y - childScrollView.contentOffset.y

        let velocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view?.superview)
        guard pointInChildScrollView > 0, pointInChildScrollView < childScrollView.bounds.height else {
            if keyboardHeight > 0 {
                childScrollView.endEditing(true)
            }
            return true
        }
        // Resting content offset under the default inset-adjustment behavior is -adjustedContentInset.top.
        let topInset = childScrollView.adjustedContentInset.top
        
        guard abs(velocity.y) > abs(velocity.x), childScrollView.contentOffset.y <= -topInset else { return false }
        
        if velocity.y < 0 {
            guard self.scrollingExpandsWhenScrolledToEdge else { return false }
            let containerHeight = height(for: self.currentSize)
            return height(for: self.orderedSizes.last) > containerHeight && containerHeight < height(for: SheetSize.fullscreen)
        } else {
            return true
        }
    }
}

extension SheetViewController: SheetContentViewDelegate {
    func pullBarTapped() {
        // Tapping the pull bar is just for accessibility
        guard UIAccessibility.isVoiceOverRunning else { return }
        let shouldDismiss = self.overlayPassesThrough && (self.dismissOnOverlayTap || self.dismissOnPull)
        guard !shouldDismiss else {
            self.attemptDismiss(animated: true)
            return
        }
        
        if self.sizes.count > 1 {
            let index = (self.sizes.firstIndex(of: self.currentSize) ?? 0) + 1
            if index >= self.sizes.count {
                self.resize(to: self.sizes[0])
            } else {
                self.resize(to: self.sizes[index])
            }
        }
    }
    
    func preferredHeightChanged(oldHeight: CGFloat, newHeight: CGFloat) {
        // A single presentation re-measures 4-5x, usually producing the identical height. Skip the
        // propagation work when nothing changed; ordered-size and accessibility updates are still
        // driven on their own paths (sizes didSet, viewIsAppearing, rotation), and keyboard resizes
        // bypass this callback entirely, so no needed update is lost.
        guard abs(oldHeight - newHeight) > 0.5 else { return }
        if self.sizes.contains(.intrinsic) {
            self.updateOrderedSizes()
        }
        // If our intrinsic size changed and that is what we are sized to currently, use that.
        // Animate with a gentle spring (blending from the current state so back-to-back changes,
        // e.g. a nav push/pop, glide rather than snap) — the detent-snap/keyboard/rotation paths
        // keep their own tuned timing. Deliberately NOT .allowUserInteraction: this uses
        // UIView.animate (not the interruptible snap animator), so letting a pan begin mid-spring
        // would capture the final model height and jump under the finger.
        if self.currentSize == .intrinsic, self.isPanning {
            // Mid-drag or mid-snap: defer, don't drop. See `hasPendingIntrinsicResize`.
            self.hasPendingIntrinsicResize = true
        } else if self.currentSize == .intrinsic {
            if self.hasAppeared {
                self.resize(to: .intrinsic,
                            duration: self.intrinsicTransitionDuration,
                            options: [.beginFromCurrentState],
                            dampingRatio: self.intrinsicTransitionDampening)
            } else {
                // Still settling into the first presentation: apply the refined measurement instantly
                // (absorbed into the present transition) so the sheet doesn't visibly nudge after it appears.
                self.resize(to: .intrinsic, animated: false)
            }
        }
    }
}

extension SheetViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = true
        return transition
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}

#endif // os(iOS)
