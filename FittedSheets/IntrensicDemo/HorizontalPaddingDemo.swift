//
//  HorizontalPaddingDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 1/4/21.
//  Copyright © 2021 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class HorizontalPaddingDemo: Demoable {
    var name: String {
        return "Horizontal Padding"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        let controller = IntrinsicExampleViewController.instantiate()
        return SheetViewController(controller: controller, options: SheetOptions(useInlineMode: useInlineMode, horizontalPadding: 20))
    }
}
