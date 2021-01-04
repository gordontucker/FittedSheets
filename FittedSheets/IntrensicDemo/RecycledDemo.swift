//
//  RecycledDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/12/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class RecycledDemo: Demoable {
    static var shared: SheetViewController?
    static var inlineShared: SheetViewController?
    var name: String {
        return "Recycled Sheet"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        guard let shared = useInlineMode ? RecycledDemo.inlineShared : RecycledDemo.shared else {
            let controller = IntrinsicExampleViewController.instantiate()
            let sheet = SheetViewController(controller: controller, options: SheetOptions(useInlineMode: useInlineMode))
            
            if useInlineMode {
                RecycledDemo.inlineShared = sheet
            } else {
                RecycledDemo.shared = sheet
            }
            return sheet
        }
        return shared
    }
}
