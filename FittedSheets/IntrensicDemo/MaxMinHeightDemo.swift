//
//  IntrensicDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 7/30/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class MaxMinHeightDemo: Demoable {
    var name: String {
        return "Max Min Height"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        let controller = IntrinsicExampleViewController.instantiate()
        let sheet = SheetViewController(controller: controller, sizes: [.intrinsic, .fixed(350)], options: SheetOptions(useInlineMode: useInlineMode))
        sheet.allowPullingPastMaxHeight = false
        sheet.allowPullingPastMinHeight = false
        return sheet
    }
}
