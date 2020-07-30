//
//  SheetDelegate.swift
//  FittedSheetsPod
//
//  Created by Gordon Tucker on 7/29/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit

public protocol SheetDelegate: class {
    func sheetViewControllerChangedSize(from: SheetSize, to: SheetSize)
}
