//
//  SheetContentViewController.swift
//  FittedSheetsPod
//
//  Created by Gordon Tucker on 7/29/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit

public class SheetContentViewController: UIViewController {
    
    public private(set) var childViewController: UIViewController
    
    private var pullBarOptions: PullBarOptions?
    private (set) var size: CGFloat = 0
    private (set) var preferredHeight: CGFloat
    
    public var contentBackgroundColor: UIColor? {
        get { self.contentView.backgroundColor }
        set { self.contentView.backgroundColor = newValue }
    }
    weak var delegate: SheetContentViewDelegate?
    
    public var contentView = UIView()
    public var pullBarView: UIView?
    public var gripView: UIView?
    
    public init(childViewController: UIViewController, pullBarOptions: PullBarOptions?) {
        self.pullBarOptions = pullBarOptions
        self.childViewController = childViewController
        self.preferredHeight = 0
        super.init(nibName: nil, bundle: nil)
        self.updatePreferredHeight()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupContentView()
        self.setupPullBarView()
        self.setupChildViewController()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updatePreferredHeight()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updatePreferredHeight()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let previousSize = self.size
        self.size = self.childViewController.view.bounds.height
        if self.size != previousSize {
            self.delegate?.childViewDidResize(oldSize: previousSize, newSize: self.size)
        }
        self.updatePreferredHeight()
    }
    
    private func updatePreferredHeight() {
        let width = self.view.bounds.width > 0 ? self.view.bounds.width : UIScreen.main.bounds.width
        let oldPreferredHeight = self.preferredHeight
        self.preferredHeight = self.view.systemLayoutSizeFitting(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height
        if oldPreferredHeight != self.preferredHeight {
            self.delegate?.preferredHeightChanged(oldHeight: oldPreferredHeight, newSize: self.preferredHeight)
        }
    }
    
    private func setupChildViewController() {
        self.childViewController.willMove(toParent: self)
        self.addChild(self.childViewController)
        self.contentView.addSubview(self.childViewController.view)
        Constraints(for: self.childViewController.view) { view in
            view.left.pin()
            view.right.pin()
            if #available(iOS 11.0, *) {
                view.bottom.pin()
                view.top.pin()
            } else if let options = self.pullBarOptions, options.cornerRadius > 0 {
                view.bottom.pin(inset: options.cornerRadius)
                view.top.pin(inset: options.height)
            } else {
                view.bottom.pin()
                view.top.pin()
            }
        }
        if #available(iOS 11.0, *), let pullBarOptions = self.pullBarOptions, pullBarOptions.shouldExtendBackground, pullBarOptions.height > 0 {
            self.childViewController.additionalSafeAreaInsets = UIEdgeInsets(top: pullBarOptions.height, left: 0, bottom: 0, right: 0)
        }
        
        self.childViewController.didMove(toParent: self)
    }

    private func setupContentView() {
        self.view.addSubview(self.contentView)
        
        Constraints(for: self.contentView) { view in
            view.top.pin()
            view.left.pin()
            view.right.pin()
            if #available(iOS 11.0, *) {
                view.bottom.pin()
            } else if let options = self.pullBarOptions, options.cornerRadius > 0 {
                view.bottom.pin(inset: -options.cornerRadius)
            } else {
                view.bottom.pin()
            }
        }
        
        if let cornerRadius = self.pullBarOptions?.cornerRadius, cornerRadius > 0 {
            self.contentView.layer.cornerRadius = cornerRadius
            self.contentView.layer.masksToBounds = true
            // Corner radius support is only on iOS 11
            if #available(iOS 11.0, *) {
                self.contentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            }
        }
    }
    
    private func setupPullBarView() {
        // If they didn't specify pull bar options, they don't want a pull bar
        guard let options = self.pullBarOptions, options.height > 0 else { return }
        let pullBarView = UIView()
        pullBarView.backgroundColor = .clear
        self.view.addSubview(pullBarView)
        Constraints(for: pullBarView) {
            $0.top.pin()
            $0.left.pin()
            $0.right.pin()
            $0.height.equal(options.height)
        }
        self.pullBarView = pullBarView
        
        let gripView = UIView()
        gripView.backgroundColor = options.gripColor
        gripView.layer.cornerRadius = options.gripSize.height / 2
        gripView.layer.masksToBounds = true
        pullBarView.addSubview(gripView)
        Constraints(for: gripView) {
            $0.centerY.align()
            $0.centerX.align()
            $0.size.equal(options.gripSize)
        }
    }
}
