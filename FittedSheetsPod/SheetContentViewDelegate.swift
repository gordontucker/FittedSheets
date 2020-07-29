//
//  SheetContentViewDelegate.swift
//  FittedSheetsPod
//
//  Created by Gordon Tucker on 7/29/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit

protocol SheetContentViewDelegate: class {
    func childViewDidResize(oldSize: CGFloat, newSize: CGFloat)
    func preferredHeightChanged(oldHeight: CGFloat, newSize: CGFloat)
}
