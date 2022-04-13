//
//  SheetViewDelegate.swift
//  FittedSheetsPod
//
//  Created by Gordon Tucker on 8/5/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit

protocol SheetViewDelegate: AnyObject {
    func sheetPoint(inside point: CGPoint, with event: UIEvent?) -> Bool
}

#endif // os(iOS) || os(tvOS) || os(watchOS)
