//
//  SheetTransitioningDelegate.swift
//  FittedSheetsPod
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit

public class SheetTransition: NSObject, UIViewControllerAnimatedTransitioning {
    public static var transitionDuration: TimeInterval = 0.3
    
    var presenting = true
    weak var presenter: UIViewController?
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
            guard let presenter = transitionContext.viewController(forKey: .from), let sheet = transitionContext.viewController(forKey: .to) as? SheetViewController else {
                transitionContext.completeTransition(true)
                return
            }
            self.presenter = presenter
            
            sheet.contentViewController.view.transform = .identity
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

                        let topSafeArea = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0
                        
                        presenter.view.layer.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, topSafeArea/2, 0), CATransform3DMakeScale(0.92, 0.92, 1))
                        presenter.view.layer.cornerRadius = self.options.presentingViewCornerRadius
                        presenter.view.layer.masksToBounds = true
                    }
                    contentView.transform = .identity
                    sheet.overlayView.alpha = 1
                },
                completion: { _ in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            )
        } else {
            guard let presenter = transitionContext.viewController(forKey: .to),
            let sheet = transitionContext.viewController(forKey: .from) as? SheetViewController else {
                transitionContext.completeTransition(true)
                return
            }
            
            containerView.addSubview(sheet.view)
            let contentView = sheet.contentViewController.contentView
            
            self.restorePresentor(
                presenter,
                animations: {
                    contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.height)
                    sheet.overlayView.alpha = 0
                }, completion: { _ in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            )
        }
    }
    
    func restorePresentor(_ presenter: UIViewController, animated: Bool = true, animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: self.duration,
            animations: {
                if self.options.shrinkPresentingViewController {
                    presenter.view.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    presenter.view.layer.cornerRadius = 0
                }
                animations?()
            },
            completion: {
                completion?($0)
            }
        )
    }
    
    func setPresentor(percentComplete: CGFloat) {
        guard self.options.shrinkPresentingViewController, let presenter = self.presenter else { return }
        let scale: CGFloat = min(1, 0.92 + (0.08 * percentComplete))
        
        let topSafeArea = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0
        
        presenter.view.layer.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, (1 - percentComplete) * topSafeArea/2, 0), CATransform3DMakeScale(scale, scale, 1))
        presenter.view.layer.cornerRadius = self.options.presentingViewCornerRadius * (1 - percentComplete)
    }
}

#endif // os(iOS) || os(tvOS) || os(watchOS)
