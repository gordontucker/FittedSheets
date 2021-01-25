//
//  HandleOptions.swift
//  FittedSheetsPod
//
//  Created by Gordon Tucker on 7/29/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit

public struct SheetOptions {
    public static var `default` = SheetOptions()
    
    public enum TransitionOverflowType {
        case color(color: UIColor)
        case view(view: UIView)
        case none
        case automatic
    }
    
    public var pullBarHeight: CGFloat = 24
    
    public var presentingViewCornerRadius: CGFloat = 12
    public var shouldExtendBackground = true
    public var setIntrinsicHeightOnNavigationControllers = true

    public var transitionAnimationOptions: UIView.AnimationOptions = [.curveEaseOut]
    public var transitionDampening: CGFloat = 0.7
    public var transitionDuration: TimeInterval = 0.4
    /// Transition velocity base value. Automatically adjusts based on the initial size of the sheet.
    public var transitionVelocity: CGFloat = 0.8
    public var transitionOverflowType: TransitionOverflowType = .automatic
    
    /// Allow the sheet to become full screen if pulled all the way to the top and not larger than the maximum size specified in sizes. Defaults to false.
    public var useFullScreenMode = true
    public var shrinkPresentingViewController = true
    /// Set true to be able to use the sheet view controller as a subview instead of a modal. Defaults to false.
    public var useInlineMode = false
    
    public var horizontalPadding: CGFloat = 0
    public var maxWidth: CGFloat?
    
    /* These properties will be removed in an upcoming release, leaving them for now so people can transition slowly */
    
    @available(*, unavailable, message: "minimumSpaceAbovePullBar is now a property on SheetViewController")
    public var minimumSpaceAbovePullBar: CGFloat = 0
    
    @available(*, unavailable, message: "gripSize is now a property on SheetViewController")
    public var gripSize: CGSize = .zero
    
    @available(*, unavailable, message: "gripColor is now a property on SheetViewController")
    public var gripColor: UIColor = .white
    
    @available(*, unavailable, message: "pullBarBackgroundColor is now a property on SheetViewController")
    public var pullBarBackgroundColor: UIColor = UIColor.clear
    
    @available(*, unavailable, message: "cornerRadius is now a property on SheetViewController")
    public var cornerRadius: CGFloat = 0
    
    public init() { }
    public init(pullBarHeight: CGFloat? = nil,
                presentingViewCornerRadius: CGFloat? = nil,
                shouldExtendBackground: Bool? = nil,
                setIntrinsicHeightOnNavigationControllers: Bool? = nil,
                useFullScreenMode: Bool? = nil,
                shrinkPresentingViewController: Bool? = nil,
                useInlineMode: Bool? = nil,
                horizontalPadding: CGFloat? = nil,
                maxWidth: CGFloat? = nil) {
        let defaultOptions = SheetOptions.default
        self.pullBarHeight = pullBarHeight ?? defaultOptions.pullBarHeight
        self.presentingViewCornerRadius = presentingViewCornerRadius ?? defaultOptions.presentingViewCornerRadius
        self.shouldExtendBackground = shouldExtendBackground ?? defaultOptions.shouldExtendBackground
        self.setIntrinsicHeightOnNavigationControllers = setIntrinsicHeightOnNavigationControllers ?? defaultOptions.setIntrinsicHeightOnNavigationControllers
        self.useFullScreenMode = useFullScreenMode ?? defaultOptions.useFullScreenMode
        self.shrinkPresentingViewController = shrinkPresentingViewController ?? defaultOptions.shrinkPresentingViewController
        self.useInlineMode = useInlineMode ?? defaultOptions.useInlineMode
        self.horizontalPadding = horizontalPadding ?? defaultOptions.horizontalPadding
        let maxWidth = maxWidth ?? defaultOptions.maxWidth
        self.maxWidth = maxWidth == 0 ? nil : maxWidth
    }
    
    @available(*, unavailable, message: "cornerRadius, minimumSpaceAbovePullBar, gripSize and gripColor are now properties on SheetViewController. Use them instead.")
    public init(pullBarHeight: CGFloat? = nil,
                gripSize: CGSize? = nil,
                gripColor: UIColor? = nil,
                cornerRadius: CGFloat? = nil,
                presentingViewCornerRadius: CGFloat? = nil,
                shouldExtendBackground: Bool? = nil,
                setIntrinsicHeightOnNavigationControllers: Bool? = nil,
                useFullScreenMode: Bool? = nil,
                shrinkPresentingViewController: Bool? = nil,
                useInlineMode: Bool? = nil,
                minimumSpaceAbovePullBar: CGFloat? = nil) {
        let defaultOptions = SheetOptions.default
        self.pullBarHeight = pullBarHeight ?? defaultOptions.pullBarHeight
        self.presentingViewCornerRadius = presentingViewCornerRadius ?? defaultOptions.presentingViewCornerRadius
        self.shouldExtendBackground = shouldExtendBackground ?? defaultOptions.shouldExtendBackground
        self.setIntrinsicHeightOnNavigationControllers = setIntrinsicHeightOnNavigationControllers ?? defaultOptions.setIntrinsicHeightOnNavigationControllers
        self.useFullScreenMode = useFullScreenMode ?? defaultOptions.useFullScreenMode
        self.shrinkPresentingViewController = shrinkPresentingViewController ?? defaultOptions.shrinkPresentingViewController
        self.useInlineMode = useInlineMode ?? defaultOptions.useInlineMode
    }
}

#endif // os(iOS) || os(tvOS) || os(watchOS)
