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
    var presenting = true
    weak var presenter: UIViewController?
    var options: SheetOptions
    
    init(options: SheetOptions) {
        self.options = options
        super.init()
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.options.transitionDuration
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
            //sheet.view.frame = containerView.frame
            Constraints(for: sheet.view) {
                $0.edges.pinToSuperview()
            }
            UIView.performWithoutAnimation {
                sheet.view.layoutIfNeeded()
            }
            sheet.contentViewController.updatePreferredHeight()
            sheet.resize(to: sheet.currentSize, animated: false)
            let contentView = sheet.contentViewController.contentView
            contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.height)
            sheet.overlayView.alpha = 0
            
            let heightPercent = contentView.bounds.height / UIScreen.main.bounds.height
            
            UIView.performWithoutAnimation {
                sheet.view.layoutIfNeeded()
            }
            
            // Use a normal animation to animate the shadown and background view
            UIView.animate(withDuration: self.options.transitionDuration * 0.6, delay: 0, options: [.curveEaseOut], animations: {
                if self.options.shrinkPresentingViewController {
                    let topSafeArea = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0
                    
                    presenter.view.layer.transform = CATransform3DConcat(CATransform3DMakeTranslation(0, topSafeArea/2, 0), CATransform3DMakeScale(0.92, 0.92, 1))
                    presenter.view.layer.cornerRadius = self.options.presentingViewCornerRadius
                    presenter.view.layer.masksToBounds = true
                }
                sheet.overlayView.alpha = 1
            }, completion: nil)

            // Use a bounce effect to animate the view in
            UIView.animate(
                withDuration: self.options.transitionDuration,
                delay: 0,
                usingSpringWithDamping: self.options.transitionDampening + ((heightPercent - 0.2) * 1.25 * 0.17),
                initialSpringVelocity: self.options.transitionVelocity * heightPercent,
                options: self.options.transitionAnimationOptions,
                animations: {
                    contentView.transform = .identity
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
            withDuration: self.options.transitionDuration,
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
