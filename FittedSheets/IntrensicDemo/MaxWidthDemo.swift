//
//  MaxWidthDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 1/4/21.
//  Copyright © 2021 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class MaxWidthDemo: Demoable {
    var name: String {
        return "Max Width"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        let controller = IntrinsicExampleViewController.instantiate()
        return SheetViewController(controller: controller, options: SheetOptions(useInlineMode: useInlineMode, maxWidth: 100))
    }
}

