//
//  HandleOptions.swift
//  FittedSheetsPod
//
//  Created by Gordon Tucker on 7/29/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit

public struct SheetOptions {
    public var pullBarHeight: CGFloat = 24
    public var gripSize = CGSize (width: 50, height: 6)
    public var gripColor = UIColor(white: 0.868, black: 0.1)
    public var cornerRadius: CGFloat = 20
    public var shouldExtendBackground = true
    public var setIntrensicHeightOnNavigationControllers = true
    
    public init() { }
}
