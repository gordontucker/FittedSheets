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
    
    public var pullBarHeight: CGFloat = 24
    
    public var presentingViewCornerRadius: CGFloat = 12
    public var shouldExtendBackground = true
    public var setIntrensicHeightOnNavigationControllers = true
    /// Allow the sheet to become full screen if pulled all the way to the top and not larger than the maximum size specified in sizes. Defaults to false.
    public var useFullScreenMode = true
    public var shrinkPresentingViewController = true
    /// Set true to be able to use the sheet view controller as a subview instead of a modal. Defaults to false.
    public var useInlineMode = false
    
    /* These properties will be removed in an upcoming release, leaving them for now so people can transition slowly */
    
    @available(*, deprecated, message: "minimumSpaceAbovePullBar is now a property on SheetViewController")
    public var minimumSpaceAbovePullBar: CGFloat {
        get { return _minimumSpaceAbovePullBar }
        set { _minimumSpaceAbovePullBar = newValue }
    }
    var _minimumSpaceAbovePullBar: CGFloat = 0
    
    @available(*, deprecated, message: "gripSize is now a property on SheetViewController")
    public var gripSize: CGSize {
        get { return _gripSize }
        set { _gripSize = newValue }
    }
    var _gripSize = CGSize (width: 50, height: 6)
    
    @available(*, deprecated, message: "gripColor is now a property on SheetViewController")
    public var gripColor: UIColor {
        get { return _gripColor }
        set { _gripColor = newValue }
    }
    var _gripColor = UIColor(white: 0.868, black: 0.1)
    
    @available(*, deprecated, message: "pullBarBackgroundColor is now a property on SheetViewController")
    public var pullBarBackgroundColor: UIColor {
        get { return _pullBarBackgroundColor }
        set { _pullBarBackgroundColor = newValue }
    }
    var _pullBarBackgroundColor = UIColor.clear
    
    @available(*, deprecated, message: "cornerRadius is now a property on SheetViewController")
    public var cornerRadius: CGFloat {
        get { return _cornerRadius }
        set { _cornerRadius = newValue }
    }
    var _cornerRadius: CGFloat = 12
    
    public init() { }
    public init(pullBarHeight: CGFloat? = nil,
                presentingViewCornerRadius: CGFloat? = nil,
                shouldExtendBackground: Bool? = nil,
                setIntrensicHeightOnNavigationControllers: Bool? = nil,
                useFullScreenMode: Bool? = nil,
                shrinkPresentingViewController: Bool? = nil,
                useInlineMode: Bool? = nil) {
        let defaultOptions = SheetOptions.default
        self.pullBarHeight = pullBarHeight ?? defaultOptions.pullBarHeight
        self._gripSize = defaultOptions._gripSize
        self._gripColor = defaultOptions._gripColor
        self._cornerRadius = defaultOptions._cornerRadius
        self.presentingViewCornerRadius = presentingViewCornerRadius ?? defaultOptions.presentingViewCornerRadius
        self.shouldExtendBackground = shouldExtendBackground ?? defaultOptions.shouldExtendBackground
        self.setIntrensicHeightOnNavigationControllers = setIntrensicHeightOnNavigationControllers ?? defaultOptions.setIntrensicHeightOnNavigationControllers
        self.useFullScreenMode = useFullScreenMode ?? defaultOptions.useFullScreenMode
        self.shrinkPresentingViewController = shrinkPresentingViewController ?? defaultOptions.shrinkPresentingViewController
        self.useInlineMode = useInlineMode ?? defaultOptions.useInlineMode
        self._minimumSpaceAbovePullBar = defaultOptions._minimumSpaceAbovePullBar
    }
    
    @available(*, deprecated, message: "cornerRadius, minimumSpaceAbovePullBar, gripSize and gripColor are now properties on SheetViewController. Use them instead.")
    public init(pullBarHeight: CGFloat? = nil,
                gripSize: CGSize? = nil,
                gripColor: UIColor? = nil,
                cornerRadius: CGFloat? = nil,
                presentingViewCornerRadius: CGFloat? = nil,
                shouldExtendBackground: Bool? = nil,
                setIntrensicHeightOnNavigationControllers: Bool? = nil,
                useFullScreenMode: Bool? = nil,
                shrinkPresentingViewController: Bool? = nil,
                useInlineMode: Bool? = nil,
                minimumSpaceAbovePullBar: CGFloat? = nil) {
        let defaultOptions = SheetOptions.default
        self.pullBarHeight = pullBarHeight ?? defaultOptions.pullBarHeight
        self._gripSize = gripSize ?? defaultOptions._gripSize
        self._gripColor = gripColor ?? defaultOptions._gripColor
        self._cornerRadius = cornerRadius ?? defaultOptions._cornerRadius
        self.presentingViewCornerRadius = presentingViewCornerRadius ?? defaultOptions.presentingViewCornerRadius
        self.shouldExtendBackground = shouldExtendBackground ?? defaultOptions.shouldExtendBackground
        self.setIntrensicHeightOnNavigationControllers = setIntrensicHeightOnNavigationControllers ?? defaultOptions.setIntrensicHeightOnNavigationControllers
        self.useFullScreenMode = useFullScreenMode ?? defaultOptions.useFullScreenMode
        self.shrinkPresentingViewController = shrinkPresentingViewController ?? defaultOptions.shrinkPresentingViewController
        self.useInlineMode = useInlineMode ?? defaultOptions.useInlineMode
        self._minimumSpaceAbovePullBar = minimumSpaceAbovePullBar ?? defaultOptions._minimumSpaceAbovePullBar
    }
}

#endif // os(iOS) || os(tvOS) || os(watchOS)
