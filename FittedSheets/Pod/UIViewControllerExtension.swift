//
//  UIViewControllerExtension.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/28/18.
//  Copyright © 2018 Gordon Tucker. All rights reserved.
//

import UIKit

extension UIViewController {
    /// The sheet view controller presenting the current view controller heiarchy (if any)
    public var sheetViewController: SheetViewController? {
        var parent = self.parent
        while let currentParent = parent {
            if let sheetViewController = currentParent as? SheetViewController {
                return sheetViewController
            } else {
                parent = currentParent.parent
            }
        }
        return nil
    }
}
