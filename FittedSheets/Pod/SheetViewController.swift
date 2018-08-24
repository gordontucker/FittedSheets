//
//  SheetViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/23/18.
//  Copyright © 2018 Gordon Tucker. All rights reserved.
//

import UIKit

class SheetViewController: UIViewController {

    var childViewController: UIViewController!
    
    weak var containerView: UIView!
    weak var pullBarView: UIView!
    
    public var preferredContainerHeight: CGFloat = 250
    
    var overlayColor: UIColor = UIColor(white: 0, alpha: 0.7) {
        didSet {
            if self.isViewLoaded {
                self.view.backgroundColor = self.overlayColor
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(controller: UIViewController) {
        
        
        self.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.childViewController == nil) {
            fatalError("SheetViewController requires a child view controller")
        }
        
        self.setUpContainerView()
        
        self.childViewController.willMove(toParentViewController: self)
        self.view.addSubview(self.childViewController.view) { (subview) in
            subview.left.pinToSuperview()
            subview.right.pinToSuperview()
            subview.bottom.pinToSuperviewMargin()
        }
        self.childViewController.view
        
        // TODO: Set up the container view with rounded corners
        
//        self.view.layer.cornerRadius = 12
//        self.view.layer.masksToBounds = true
    }
    
    func setUpContainerView() {
        let containerView = UIView(frame: CGRect.zero)
        self.view.addSubview(containerView) { (subview) in
            subview.left.pinToSuperview()
            subview.right.pinToSuperview()
            subview.bottom.pinToSuperview()
            subview.height.set(self.preferredContainerHeight).priority = UILayoutPriority(240)
        }
        containerView.backgroundColor = UIColor.clear
        self.containerView = containerView
        
        // Add a background with only the top rounded
        // First add the rounded corners
        let roundedCornersView = UIView(frame: CGRect.zero)
        containerView.addSubview(roundedCornersView) { (subview) in
            subview.top.pinToSuperview()
            subview.left.pinToSuperview()
        }
    }
    
    func setUpPullBarView() {
        let pullBarView = UIView(frame: CGRect.zero)
        self.containerView.addSubview(pullBarView) { (subview) in
            subview.top.pinToSuperview()
            subview.left.pinToSuperview()
            subview.right.pinToSuperview()
            subview.height.set(44)
        }
        self.pullBarView = pullBarView
        
        let grabView = UIView(frame: CGRect.zero)
        pullBarView.addSubview(grabView) { (subview) in
            subview.centerY.alignWithSuperview()
            subview.centerX.alignWithSuperview()
            subview.size.set(CGSize(width: 100, height: 20))
        }
        grabView.layer.cornerRadius = 10
        grabView.layer.masksToBounds = true
        grabView.backgroundColor = UIColor(white: 0.868, alpha: 1)
    }
}
