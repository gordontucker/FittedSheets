//
//  SheetDockSize.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/27/18.
//  Copyright © 2018 Gordon Tucker. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import CoreGraphics

public enum SheetSize: Equatable {
    case intrensic
    case fixed(CGFloat)
    case fullscreen
    case percent(Float)
}

#endif // os(iOS) || os(tvOS) || os(watchOS)
