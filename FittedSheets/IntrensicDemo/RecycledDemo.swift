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
    var name: String {
        return "Recycled Sheet"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        guard let shared = RecycledDemo.shared else {
            let controller = IntrinsicExampleViewController.instantiate()
            let sheet = SheetViewController(controller: controller, options: SheetOptions(useInlineMode: useInlineMode))
            RecycledDemo.shared = sheet
            return sheet
        }
        return shared
    }
}
