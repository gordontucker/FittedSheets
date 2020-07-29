//
//  SheetDockSize.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/27/18.
//  Copyright © 2018 Gordon Tucker. All rights reserved.
//

import CoreGraphics

public enum SheetSize {
    case intrensic
    case fixed(CGFloat)
    case halfScreen
    case fullScreen
    case percent(Float)
}
