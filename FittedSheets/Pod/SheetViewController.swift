//
//  SheetViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/23/18.
//  Copyright © 2018 Gordon Tucker. All rights reserved.
//

import UIKit

protocol ScrollableSheetProtocol {
    var sheetScrollView: UIScrollView? { get }
}

extension ScrollableSheetProtocol {
    var sheetScrollView: UIScrollView? { return nil }
}

extension UIViewController {
    var sheetViewController: SheetViewController? {
        var parent = self.parent
        while let currentParent = parent {
            if let sheetViewController = currentParent as? SheetViewController {
                return sheetViewController
            } else {
                parent = currentParent.parent
            }
        }
        return nil
    }
}

class SheetViewController: UIViewController {

    var childViewController: UIViewController!
    
    weak var containerView: UIView!
    weak var pullBarView: UIView!
    
    public var dismissOnBackgroundTap: Bool = true
    
    private var containerSize: SheetSize = .fixed(250)
    private var actualContainerSize: SheetSize = .fixed(250)
    private var orderedSheetSizes: [SheetSize] = [.fixed(250), .fullScreen]
    
    public var firstPanPoint: CGPoint = CGPoint.zero
    private var panGestureRecognizer: InitialTouchPanGestureRecognizer!
    private weak var childScrollView: UIScrollView?
    
    private var containerHeightConstraint: NSLayoutConstraint!
    
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
    
    convenience init(controller: UIViewController, sizes: [SheetSize] = []) {
        self.init(nibName: nil, bundle: nil)
        self.childViewController = controller
        if sizes.count > 0 {
            self.setSizes(sizes)
        }
        self.modalPresentationStyle = .overFullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.childViewController == nil) {
            fatalError("SheetViewController requires a child view controller")
        }
        
        self.view.backgroundColor = UIColor.clear
        self.setUpContainerView()
        self.setUpDismissView()
        
        let panGestureRecognizer = InitialTouchPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        self.panGestureRecognizer = panGestureRecognizer
        
        self.childViewController.willMove(toParentViewController: self)
        self.addChildViewController(self.childViewController)
        self.containerView.addSubview(self.childViewController.view) { (subview) in
            subview.left.pinToSuperview()
            subview.right.pinToSuperview()
            let bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            subview.bottom.pinToSuperview(inset: bottomInset, relation: .equal)
            subview.top.pinToSuperview(inset: 24, relation: .equal)
        }
        self.childViewController.didMove(toParentViewController: self)
        
        self.setUpPullBarView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: { [weak self] in
            guard let _self = self else { return }
            _self.view.backgroundColor = _self.overlayColor
            _self.containerView.transform = CGAffineTransform.identity
            _self.actualContainerSize = .fixed(_self.containerView.frame.height)
        }, completion: nil)
    }
    
    func setSizes(_ sizes: [SheetSize]) {
        guard sizes.count > 0 else {
            print("You cannot set sheet sizes to an empty array")
            return
        }
        self.orderedSheetSizes = sizes.sorted(by: { $0.height < $1.height })
        self.containerSize = sizes[0]
        self.actualContainerSize = sizes[0]
    }
    
    func setUpOverlay() {
        let overlay = UIView(frame: CGRect.zero)
        overlay.backgroundColor = self.overlayColor
        self.view.addSubview(overlay) { (subview) in
            subview.edges.pinToSuperview()
        }
    }
    
    func setUpContainerView() {
        let containerView = UIView(frame: CGRect.zero)
        self.view.addSubview(containerView) { (subview) in
            subview.left.pinToSuperview()
            subview.right.pinToSuperview()
            subview.bottom.pinToSuperview()
            let topInset = max(20, UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
            print("topInset: \(topInset)")
            subview.top.pinToSuperview(inset: topInset, relation: .greaterThanOrEqual)
            self.containerHeightConstraint = subview.height.set(self.containerSize.height)
            self.containerHeightConstraint.priority = UILayoutPriority(998)
        }
        containerView.backgroundColor = UIColor.clear
        self.containerView = containerView
        
        // Add a background with only the top rounded
        // First add the rounded corners
        let roundedCornersView = UIView(frame: CGRect.zero)
        containerView.addSubview(roundedCornersView) { (subview) in
            subview.top.pinToSuperview()
            subview.left.pinToSuperview()
            subview.right.pinToSuperview()
            subview.height.set(20)
        }
        roundedCornersView.layer.cornerRadius = 10
        roundedCornersView.layer.masksToBounds = true
        roundedCornersView.backgroundColor = UIColor.white
        
        let solidBackgroundView = UIView(frame: CGRect.zero)
        containerView.addSubview(solidBackgroundView) { (subview) in
            subview.top.pinToSuperview(inset: 10, relation: .equal)
            subview.left.pinToSuperview()
            subview.right.pinToSuperview()
            subview.bottom.pinToSuperview()
        }
        solidBackgroundView.backgroundColor = UIColor.white
        
        containerView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
    }
    
    func setUpDismissView() {
        let dismissAreaView = UIView(frame: CGRect.zero)
        self.view.addSubview(dismissAreaView, containerView) { (dismissAreaView, containerView) in
            dismissAreaView.top.pinToSuperview()
            dismissAreaView.left.pinToSuperview()
            dismissAreaView.right.pinToSuperview()
            dismissAreaView.bottom.align(with: containerView.top)
        }
        dismissAreaView.backgroundColor = UIColor.clear
        dismissAreaView.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissTapped))
        dismissAreaView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setUpPullBarView() {
        let pullBarView = UIView(frame: CGRect.zero)
        self.containerView.addSubview(pullBarView) { (subview) in
            subview.top.pinToSuperview()
            subview.left.pinToSuperview()
            subview.right.pinToSuperview()
            subview.height.set(24)
        }
        self.pullBarView = pullBarView
        
        let grabView = UIView(frame: CGRect.zero)
        pullBarView.addSubview(grabView) { (subview) in
            subview.centerY.alignWithSuperview()
            subview.centerX.alignWithSuperview()
            subview.size.set(CGSize(width: 70, height: 6))
        }
        grabView.layer.cornerRadius = 3
        grabView.layer.masksToBounds = true
        grabView.backgroundColor = UIColor(white: 0.868, alpha: 1)
    }
    
    @objc func dismissTapped() {
        guard dismissOnBackgroundTap else { return }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: { [weak self] in
            self?.containerView.transform = CGAffineTransform(translationX: 0, y: self?.containerView.frame.height ?? 0)
            self?.view.backgroundColor = UIColor.clear
        }, completion: { [weak self] complete in
            self?.dismiss(animated: false, completion: nil)
        })
    }
    
    @objc func panned(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.translation(in: gesture.view?.superview)
        if gesture.state == .began {
            print("began")
            self.firstPanPoint = point
            self.actualContainerSize = .fixed(self.containerView.frame.height)
        }
        
        let minHeight = self.orderedSheetSizes.first?.height ?? 0
        let maxHeight = self.orderedSheetSizes.last?.height ?? 0
        
        if gesture.state == .cancelled || gesture.state == .failed {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.transform = CGAffineTransform.identity
                self.containerHeightConstraint.constant = self.containerSize.height
            }, completion: nil)
        } else if gesture.state == .ended {
            let velocity = (0.2 * gesture.velocity(in: self.view).y)
            var finalHeight = containerView.frame.height - velocity
            if velocity > 300 {
                // They swiped hard, always just close the sheet when they do
                finalHeight = -1
            }
            
            let animationDuration = TimeInterval(abs(velocity*0.0002) + 0.2)
            print("v:\(velocity), finalY: \(finalHeight), height: \(containerView.frame.height)")
            
            guard finalHeight >= minHeight else {
                // Dismiss
                UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut], animations: { [weak self] in
                    self?.containerView.transform = CGAffineTransform(translationX: 0, y: self?.containerView.frame.height ?? 0)
                    self?.view.backgroundColor = UIColor.clear
                }, completion: { [weak self] complete in
                    self?.dismiss(animated: false, completion: nil)
                })
                return
            }
            
            var newSize = self.containerSize
            if point.y < 0 {
                // We need to move to the next larger one
                print("switching to a larger size, if available")
                newSize = self.orderedSheetSizes.last ?? self.containerSize
                for size in self.orderedSheetSizes.reversed() {
                    if finalHeight < size.height {
                        newSize = size
                    } else {
                        break
                    }
                }
            } else {
                print("switching to a smaller size, if available")
                // We need to move to the next smaller one
                newSize = self.orderedSheetSizes.first ?? self.containerSize
                for size in self.orderedSheetSizes {
                    if finalHeight > size.height {
                        newSize = size
                    } else {
                        break
                    }
                }
            }
            print("new size: \(newSize)")
            self.containerSize = newSize
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.transform = CGAffineTransform.identity
                self.containerHeightConstraint.constant = newSize.height
                self.view.layoutIfNeeded()
            }, completion: { [weak self] complete in
                guard let _self = self else { return }
                _self.actualContainerSize = .fixed(_self.containerView.frame.height)
            })
        } else {
            var newHeight = max(0, self.actualContainerSize.height + (self.firstPanPoint.y - point.y))
            var offset: CGFloat = 0
            if newHeight < minHeight {
                offset = minHeight - newHeight
                newHeight = minHeight
            }
            if newHeight > maxHeight {
                newHeight = maxHeight
            }
            
            Constraints(for: self.containerView) { (containerView) in
                self.containerHeightConstraint.constant = newHeight
            }
            
            if offset > 0 {
                self.containerView.transform = CGAffineTransform(translationX: 0, y: offset)
            } else {
                self.containerView.transform = CGAffineTransform.identity
            }
            
        }
    }
    
    func handleScrollView(_ scrollView: UIScrollView) {
        scrollView.panGestureRecognizer.require(toFail: panGestureRecognizer)
        self.childScrollView = scrollView
    }
}

extension SheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? InitialTouchPanGestureRecognizer, let childScrollView = self.childScrollView, let point = panGestureRecognizer.initialTouchLocation else { return true }
        
        let pointInChildScrollView: CGPoint = self.view.convert(point, to: childScrollView)
        
        print(">> begin at \(pointInChildScrollView.y)?")
        guard pointInChildScrollView.y > 0 else { return true }
        
        let velocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view?.superview)
        guard abs(velocity.y) > abs(velocity.x), childScrollView.contentOffset.y == 0 else { return false }
        
        if velocity.y < 0 {
            print("scrolling up")
            return self.orderedSheetSizes.last?.height ?? 0 > self.containerSize.height && self.containerSize.height < SheetSize.fullScreen.height
        } else {
            print("scrolling down")
            return true
        }
    }
}
