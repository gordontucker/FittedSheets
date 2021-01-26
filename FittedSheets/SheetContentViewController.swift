//
//  SheetContentViewController.swift
//  FittedSheetsPod
//
//  Created by Gordon Tucker on 7/29/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit

public class SheetContentViewController: UIViewController {
    
    public private(set) var childViewController: UIViewController
    
    private var options: SheetOptions
    private (set) var size: CGFloat = 0
    private (set) var preferredHeight: CGFloat
    
    public var contentBackgroundColor: UIColor? {
        get { self.childContainerView.backgroundColor }
        set { self.childContainerView.backgroundColor = newValue }
    }
    
    public var cornerRadius: CGFloat = 0 {
        didSet {
            self.updateCornerRadius()
        }
    }
    
    public var gripSize: CGSize = CGSize(width: 50, height: 6) {
        didSet {
            self.gripSizeConstraints.forEach({ $0.isActive = false })
            Constraints(for: self.gripView) {
                self.gripSizeConstraints = $0.size.set(self.gripSize)
            }
            self.gripView.layer.cornerRadius = self.gripSize.height / 2
        }
    }
    
    public var gripColor: UIColor? {
        get { return self.gripView.backgroundColor }
        set { self.gripView.backgroundColor = newValue }
    }
    
    public var pullBarBackgroundColor: UIColor? {
        get { return self.pullBarView.backgroundColor }
        set { self.pullBarView.backgroundColor = newValue }
    }
    public var treatPullBarAsClear: Bool = SheetViewController.treatPullBarAsClear {
        didSet {
            if self.isViewLoaded {
                self.updateCornerRadius()
            }
        }
    }
    
    weak var delegate: SheetContentViewDelegate?
    
    public var contentWrapperView = UIView()
    public var contentView = UIView()
    private var contentTopConstraint: NSLayoutConstraint?
    private var contentBottomConstraint: NSLayoutConstraint?
    private var navigationHeightConstraint: NSLayoutConstraint?
    private var gripSizeConstraints: [NSLayoutConstraint] = []
    public var childContainerView = UIView()
    public var pullBarView = UIView()
    public var gripView = UIView()
    private let overflowView = UIView()
    
    public init(childViewController: UIViewController, options: SheetOptions) {
        self.options = options
        self.childViewController = childViewController
        self.preferredHeight = 0
        super.init(nibName: nil, bundle: nil)
        
        if options.setIntrinsicHeightOnNavigationControllers, let navigationController = self.childViewController as? UINavigationController {
            navigationController.delegate = self
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupContentView()
        self.setupChildContainerView()
        self.setupPullBarView()
        self.setupChildViewController()
        self.updatePreferredHeight()
        self.updateCornerRadius()
        self.setupOverflowView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.performWithoutAnimation {
            self.view.layoutIfNeeded()
        }
        self.updatePreferredHeight()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updatePreferredHeight()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateAfterLayout()
    }
    
    func updateAfterLayout() {
        self.size = self.childViewController.view.bounds.height
        //self.updatePreferredHeight()
    }
    
    func adjustForKeyboard(height: CGFloat) {
        self.updateChildViewControllerBottomConstraint(adjustment: -height)
    }
    
    private func updateCornerRadius() {
        self.contentWrapperView.layer.cornerRadius = self.treatPullBarAsClear ? 0 : self.cornerRadius
        self.childContainerView.layer.cornerRadius = self.treatPullBarAsClear ? self.cornerRadius : 0
    }
    
    private func setupOverflowView() {
        switch (self.options.transitionOverflowType) {
            case .view(view: let view):
                overflowView.backgroundColor = .clear
                overflowView.addSubview(view) {
                    $0.edges.pinToSuperview()
                }
            case .automatic:
                overflowView.backgroundColor = self.childViewController.view.backgroundColor
            case .color(color: let color):
                overflowView.backgroundColor = color
            case .none:
                overflowView.backgroundColor = .clear
        }
    }
    
    private func updateNavigationControllerHeight() {
        // UINavigationControllers don't set intrinsic size, this is a workaround to fix that
        guard self.options.setIntrinsicHeightOnNavigationControllers, let navigationController = self.childViewController as? UINavigationController else { return }
        self.navigationHeightConstraint?.isActive = false
        self.contentTopConstraint?.isActive = false
        
        if let viewController = navigationController.visibleViewController {
           let size = viewController.view.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: 0))
        
            if self.navigationHeightConstraint == nil {
                self.navigationHeightConstraint = navigationController.view.heightAnchor.constraint(equalToConstant: size.height)
            } else {
                self.navigationHeightConstraint?.constant = size.height
            }
        }
        self.navigationHeightConstraint?.isActive = true
        self.contentTopConstraint?.isActive = true
    }
    
    func updatePreferredHeight() {
        self.updateNavigationControllerHeight()
        let width = self.view.bounds.width > 0 ? self.view.bounds.width : UIScreen.main.bounds.width
        let oldPreferredHeight = self.preferredHeight
        var fittingSize = UIView.layoutFittingCompressedSize;
        fittingSize.width = width;
        
        self.contentTopConstraint?.isActive = false
        UIView.performWithoutAnimation {
            self.contentView.layoutSubviews()
        }
        
        self.preferredHeight = self.contentView.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow).height
        self.contentTopConstraint?.isActive = true
        UIView.performWithoutAnimation {
            self.contentView.layoutSubviews()
        }
        
        self.delegate?.preferredHeightChanged(oldHeight: oldPreferredHeight, newSize: self.preferredHeight)
    }
    
    private func updateChildViewControllerBottomConstraint(adjustment: CGFloat) {
        self.contentBottomConstraint?.constant = adjustment
    }
    
    private func setupChildViewController() {
        self.childViewController.willMove(toParent: self)
        self.addChild(self.childViewController)
        self.childContainerView.addSubview(self.childViewController.view)
        Constraints(for: self.childViewController.view) { view in
            view.left.pinToSuperview()
            view.right.pinToSuperview()
            self.contentBottomConstraint = view.bottom.pinToSuperview()
                view.top.pinToSuperview()
        }
        if self.options.shouldExtendBackground, self.options.pullBarHeight > 0 {
            self.childViewController.additionalSafeAreaInsets = UIEdgeInsets(top: self.options.pullBarHeight, left: 0, bottom: 0, right: 0)
        }
        
        self.childViewController.didMove(toParent: self)
        
        self.childContainerView.layer.masksToBounds = true
        self.childContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

    private func setupContentView() {
        self.view.addSubview(self.contentView)
        Constraints(for: self.contentView) {
            $0.left.pinToSuperview()
            $0.right.pinToSuperview()
            $0.bottom.pinToSuperview()
            self.contentTopConstraint = $0.top.pinToSuperview()
        }
        self.contentView.addSubview(self.contentWrapperView) {
            $0.edges.pinToSuperview()
        }
        
        self.contentWrapperView.layer.masksToBounds = true
        self.contentWrapperView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
                
        self.contentView.addSubview(overflowView) {
            $0.edges(.left, .right).pinToSuperview()
            $0.height.set(200)
            $0.top.align(with: self.contentView.al.bottom - 1)
        }
    }
    
    private func setupChildContainerView() {
        self.contentWrapperView.addSubview(self.childContainerView)
        
        Constraints(for: self.childContainerView) { view in
            
            if self.options.shouldExtendBackground {
                view.top.pinToSuperview()
            } else {
                view.top.pinToSuperview(inset: self.options.pullBarHeight)
            }
            view.left.pinToSuperview()
            view.right.pinToSuperview()
            view.bottom.pinToSuperview()
        }
    }
    
    private func setupPullBarView() {
        // If they didn't specify pull bar options, they don't want a pull bar
        guard self.options.pullBarHeight > 0 else { return }
        let pullBarView = self.pullBarView
        pullBarView.isUserInteractionEnabled = true
        pullBarView.backgroundColor = self.pullBarBackgroundColor
        self.contentWrapperView.addSubview(pullBarView)
        Constraints(for: pullBarView) {
            $0.top.pinToSuperview()
            $0.left.pinToSuperview()
            $0.right.pinToSuperview()
            $0.height.set(options.pullBarHeight)
        }
        self.pullBarView = pullBarView
        
        let gripView = self.gripView
        gripView.backgroundColor = self.gripColor
        gripView.layer.cornerRadius = self.gripSize.height / 2
        gripView.layer.masksToBounds = true
        pullBarView.addSubview(gripView)
        self.gripSizeConstraints.forEach({ $0.isActive = false })
        Constraints(for: gripView) {
            $0.centerY.alignWithSuperview()
            $0.centerX.alignWithSuperview()
            self.gripSizeConstraints = $0.size.set(self.gripSize)
        }
        
        pullBarView.isAccessibilityElement = true
        pullBarView.accessibilityIdentifier = "pull-bar"
        // This will be overriden whenever the sizes property is changed on SheetViewController
        pullBarView.accessibilityLabel = Localize.dismissPresentation.localized
        pullBarView.accessibilityTraits = [.button]
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pullBarTapped))
        pullBarView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func pullBarTapped(_ gesture: UITapGestureRecognizer) {
        self.delegate?.pullBarTapped()
    }
}

extension SheetContentViewController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        navigationController.view.endEditing(true)
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.navigationHeightConstraint?.isActive = true
        self.updatePreferredHeight()
    }
}

#endif // os(iOS) || os(tvOS) || os(watchOS)
