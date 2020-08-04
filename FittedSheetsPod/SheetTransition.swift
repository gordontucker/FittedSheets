//
//  SheetTransitioningDelegate.swift
//  FittedSheetsPod
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit

public class SheetTransition: NSObject, UIViewControllerAnimatedTransitioning {
    public static var transitionDuration: TimeInterval = 0.3
    
    var presenting = true
    var presentor: UIViewController?
    var options: SheetOptions
    var duration = SheetTransition.transitionDuration
    
    init(options: SheetOptions) {
        self.options = options
        super.init()
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        if self.presenting {
            guard let presentor = transitionContext.viewController(forKey: .from), let sheet = transitionContext.viewController(forKey: .to) as? SheetViewController else {
                transitionContext.completeTransition(true)
                return
            }
            self.presentor = presentor
            
            containerView.addSubview(sheet.view)
            sheet.view.setNeedsLayout()
            sheet.view.layoutIfNeeded()
            sheet.contentViewController.updatePreferredHeight()
            sheet.resize(to: sheet.currentSize, animated: false)
            let contentView = sheet.contentViewController.contentView
            contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.height)
            sheet.overlayView.alpha = 0
            
            UIView.animate(
                withDuration: self.duration,
                animations: {
                    if self.options.shrinkPresentingViewController {
                        presentor.view.layer.transform = CATransform3DMakeScale(0.88, 0.88, 1)
                        presentor.view.layer.cornerRadius = self.options.presentingViewCornerRadius
                        presentor.view.layer.masksToBounds = true
                    }
                    contentView.transform = .identity
                    sheet.overlayView.alpha = 1
                },
                completion: { _ in
                    presentor.endAppearanceTransition()
                    sheet.endAppearanceTransition()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            )
        } else {
            guard let presentor = transitionContext.viewController(forKey: .to),
            let sheet = transitionContext.viewController(forKey: .from) as? SheetViewController else {
                transitionContext.completeTransition(true)
                return
            }
            
            containerView.addSubview(sheet.view)
            let contentView = sheet.contentViewController.contentView
            
            self.restorePresentor(
                presentor,
                animations: {
                    contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.height)
                    sheet.overlayView.alpha = 0
                }, completion: { _ in
                    sheet.endAppearanceTransition()
                    presentor.endAppearanceTransition()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            )
        }
    }
    
    func restorePresentor(_ presentor: UIViewController, animated: Bool = true, animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: self.duration,
            animations: {
                presentor.view.layer.transform = CATransform3DMakeScale(1, 1, 1)
                presentor.view.layer.cornerRadius = 0
                animations?()
            },
            completion: {
                completion?($0)
            }
        )
    }
    
    func setPresentor(percentComplete: CGFloat) {
        guard self.options.shrinkPresentingViewController, let presentor = self.presentor else { return }
        let scale: CGFloat = min(1, 0.88 + (0.12 * percentComplete))
        presentor.view.layer.transform = CATransform3DMakeScale(scale, scale, 1)
        presentor.view.layer.cornerRadius = self.options.presentingViewCornerRadius * (1 - percentComplete)
    }
}
