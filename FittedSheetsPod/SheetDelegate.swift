//
//  SheetDelegate.swift
//  FittedSheetsPod
//
//  Created by Gordon Tucker on 7/29/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit

public protocol SheetDelegate: class {
    func sheetViewControllerChangedSize(to: CGFloat)
    /// Determine if inline presented sheets should dismiss
    func sheetViewControllerShouldDismiss() -> Bool
    /// The inline presented sheets was dismissed
    func sheetViewControllerDidDismiss()
}

public extension SheetDelegate {
    func sheetViewControllerShouldDismiss() -> Bool { return true }
    func sheetViewControllerDidDismiss() { }
    func sheetViewControllerChangedSize(to: CGFloat) { }
}

#endif // os(iOS) || os(tvOS) || os(watchOS)
