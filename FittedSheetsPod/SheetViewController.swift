//
//  SheetViewController.swift
//  FittedSheetsPod
//
//  Created by Gordon Tucker on 7/29/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit

public class SheetViewController: UIViewController {
    
    /// Options for the pull bar. Set to nil if no pull bar is desired
    public var pullBarOptions: PullBarOptions? = PullBarOptions()
    /// Automatically grow/move the sheet to accomidate the keyboard. Defaults to false.
    public var autoAdjustToKeyboard = false
    /// Allow pulling past the maximum height and bounce back. Defaults to true.
    public var allowPullingPastMaxHeight = true
    /// Allow the sheet to become full screen if pulled all the way to the top and not larger than the maximum size specified in sizes. Defaults to true.
    public var useFullScreenMode = true
    /// The maximum width of the sheet
    public var maxWidth: CGFloat?
    /// The sizes that the sheet will attempt to pin to. Defaults to intrensic only.
    public var sizes: [SheetSize] = [.intrensic]
    public var orderedSizes: [SheetSize] {
        return self.sizes
    }
    public private(set) var currentSize: SheetSize = .intrensic
    /// Allows dismissing of the sheet by pulling down
    public var dismissOnPull: Bool = true
    /// Dismisses the sheet by tapping on the background overlay
    public var dismissOnOverlayTap: Bool = true
    ///
    public var shouldRecognizePanGestureWithUIControls: Bool = true
    /// The color of the overlay background
    public var overlayColor = UIColor(white: 0, alpha: 0.7) {
        didSet {
            self.overlayView.backgroundColor = self.overlayColor
        }
    }
    
    public private(set) var contentViewController: SheetContentViewController
    var overlayView = UIView()
    private var contentViewHeightConstraint: NSLayoutConstraint!
    
    /// The child view controller's scroll view we are watching so we can override the pull down/up to work on the sheet when needed
    private weak var childScrollView: UIScrollView?
    
    private var keyboardHeight: CGFloat = 0
    private var firstPanPoint: CGPoint = CGPoint.zero
    private var panOffset: CGFloat = 0
    private var panGestureRecognizer: InitialTouchPanGestureRecognizer!
    
    public init(childViewController: UIViewController, sizes: [SheetSize] = [.intrensic], pullBarOptions: PullBarOptions? = PullBarOptions()) {
        self.contentViewController = SheetContentViewController(childViewController: childViewController, pullBarOptions: pullBarOptions)
        self.sizes = sizes
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        self.addOverlay()
        self.addContentView()
        self.addOverlayTapView()
        self.registerKeyboardObservers()
        self.resize(to: self.sizes.first ?? .intrensic, animated: false)
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
    
    private func addOverlay() {
        self.view.addSubview(self.overlayView)
        Constraints(for: self.overlayView) {
            $0.edges.pin()
        }
        self.overlayView.backgroundColor = self.overlayColor
    }
    
    private func addOverlayTapView() {
        let overlayTapView = UIView()
        overlayTapView.backgroundColor = .clear
        overlayTapView.isUserInteractionEnabled = true
        self.view.addSubview(overlayTapView)
        Constraints(for: overlayTapView, self.contentViewController.view) {
            $0.top.pin()
            $0.left.pin()
            $0.right.pin()
            $0.bottom.spacing(0, to: $1.top)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        overlayTapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func overlayTapped(_ gesture: UITapGestureRecognizer) {
        guard self.dismissOnOverlayTap else { return }
        self.dismiss(animated: true, completion: nil)
    }

    private func addContentView() {
        self.contentViewController.willMove(toParent: self)
        self.addChild(self.contentViewController)
        self.view.addSubview(self.contentViewController.view)
        self.contentViewController.didMove(toParent: self)
        self.contentViewController.delegate = self
        Constraints(for: self.contentViewController.view) {
            $0.edges.pin(insets: 0, axis: .horizontal, alignment: .center)
            $0.left.pin().priority = UILayoutPriority(999)
            $0.bottom.pin()
            if (self.useFullScreenMode) {
                $0.top.pin()
            } else {
                var safeAreaTop: CGFloat = 20
                if #available(iOS 11.0, *) {
                    safeAreaTop = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 20
                }
                $0.top.pin(inset: max(safeAreaTop, 20))
            }
        }
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
        }
        
        let minHeight: CGFloat = 0
        let maxHeight = self.view.bounds.height
        
        var newHeight = max(0, self.contentViewController.view.bounds.height + (self.firstPanPoint.y - point.y))
        var offset: CGFloat = 0
        if newHeight < minHeight {
            offset = minHeight - newHeight
            newHeight = minHeight
        }
        if newHeight > maxHeight {
            newHeight = maxHeight
        }
        
        switch gesture.state {
            case .cancelled, .failed:
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                    self.contentViewController.view.transform = CGAffineTransform.identity
                    self.contentViewHeightConstraint.constant = self.height(for: self.currentSize)
                }, completion: nil)
            
            case .began, .changed:
                self.contentViewHeightConstraint.constant = newHeight
                
                if offset > 0 {
                    self.contentViewController.view.transform = CGAffineTransform(translationX: 0, y: offset)
                } else {
                    self.contentViewController.view.transform = CGAffineTransform.identity
                }
            case .ended:
                let velocity = (0.2 * gesture.velocity(in: self.view).y)
                var finalHeight = newHeight - offset - velocity
                if velocity > 500 {
                    // They swiped hard, always just close the sheet when they do
                    finalHeight = -1
                }
                
                let animationDuration = TimeInterval(abs(velocity*0.0002) + 0.2)
                
                guard finalHeight >= (minHeight / 2) || !self.dismissOnPull else {
                    // Dismiss
                    UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut], animations: { [weak self] in
                        self?.contentViewController.view.transform = CGAffineTransform(translationX: 0, y: self?.contentViewController.view.bounds.height ?? 0)
                        self?.view.backgroundColor = UIColor.clear
                    }, completion: { [weak self] complete in
                        self?.dismiss(animated: false, completion: nil)
                    })
                    return
                }
                
                var newSize = self.currentSize
                if point.y < 0 {
                    // We need to move to the next larger one
                    newSize = self.orderedSizes.last ?? self.currentSize
                    for size in self.orderedSizes.reversed() {
                        if finalHeight < self.height(for: size) {
                            newSize = size
                        } else {
                            break
                        }
                    }
                } else {
                    // We need to move to the next smaller one
                    newSize = self.orderedSizes.first ?? self.currentSize
                    for size in self.orderedSizes {
                        if finalHeight > self.height(for: size) {
                            newSize = size
                        } else {
                            break
                        }
                    }
                }
                self.currentSize = newSize
                
                UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut], animations: {
                    self.contentViewController.view.transform = CGAffineTransform.identity
                    self.contentViewHeightConstraint.constant = self.height(for: newSize)
                    self.view.layoutIfNeeded()
                }, completion: { complete in
                    //guard let self = self else { return }
                    //? self.actualContainerSize = .fixed(self.containerView.frame.height)
                })
            case .possible:
                break
            @unknown default:
                break // Do nothing
        }
    }
    
    private func registerKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDismissed(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardShown(_ notification: Notification) {
        guard let info:[AnyHashable: Any] = notification.userInfo, let keyboardRect:CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let windowRect = self.view.convert(self.view.bounds, to: nil)
        let actualHeight = windowRect.maxY - keyboardRect.origin.y
        self.adjustForKeyboard(height: actualHeight, from: notification)
    }
    
    @objc func keyboardDismissed(_ notification: Notification) {
        self.adjustForKeyboard(height: 0, from: notification)
    }
    
    private func adjustForKeyboard(height: CGFloat, from notification: Notification) {
        guard let info:[AnyHashable: Any] = notification.userInfo else { return }
        self.keyboardHeight = height
        
        let duration:TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        self.resize(to: self.currentSize, duration: duration, options: animationCurve, animated: true)
    }
    
    private func height(for size: SheetSize?) -> CGFloat {
        guard let size = size else { return 0 }
        let contentHeight: CGFloat
        switch (size) {
            case .fixed(let height):
                contentHeight = height + self.keyboardHeight
            case .fullScreen:
                if #available(iOS 11.0, *) {
                    contentHeight = self.view.bounds.height - self.view.safeAreaInsets.top + self.keyboardHeight
                } else {
                    contentHeight = self.view.bounds.height + self.keyboardHeight
                }
            case .halfScreen:
                contentHeight = (self.view.bounds.height) / 2 + self.keyboardHeight
            case .intrensic:
                contentHeight = self.contentViewController.preferredHeight
            case .percent(let percent):
                contentHeight = (self.view.bounds.height) * CGFloat(percent) + self.keyboardHeight
        }
        return contentHeight
    }
    
    public func resize(to size: SheetSize,
                       duration: TimeInterval = 0.2,
                       options: UIView.AnimationOptions = [.curveEaseOut],
                       animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: { [weak self] in
                guard let self = self, let constraint = self.contentViewHeightConstraint else { return }
                constraint.constant = self.height(for: size)
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.contentViewHeightConstraint?.constant = self.height(for: size)
        }
        self.currentSize = size
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
        guard let panGestureRecognizer = gestureRecognizer as? InitialTouchPanGestureRecognizer, let childScrollView = self.childScrollView, let point = panGestureRecognizer.initialTouchLocation else { return true }
        
        let pointInChildScrollView = self.view.convert(point, to: childScrollView).y - childScrollView.contentOffset.y
        
        let velocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view?.superview)
        guard pointInChildScrollView > 0, pointInChildScrollView < childScrollView.bounds.height else {
            if keyboardHeight > 0 {
                childScrollView.endEditing(true)
            }
            return true
        }
        let topInset = childScrollView.contentInset.top
        guard abs(velocity.y) > abs(velocity.x), childScrollView.contentOffset.y == -topInset else { return false }
        
        if velocity.y < 0 {
            let containerHeight = height(for: self.currentSize)
            return height(for: self.orderedSizes.last) > containerHeight && containerHeight < height(for: SheetSize.fullScreen)
        } else {
            return true
        }
    }
}

extension SheetViewController: SheetContentViewDelegate {
    func childViewDidResize(oldSize: CGFloat, newSize: CGFloat) {
        
    }
    
    func preferredHeightChanged(oldHeight: CGFloat, newSize: CGFloat) {
        
    }
}

#endif // os(iOS) || os(tvOS) || os(watchOS)
