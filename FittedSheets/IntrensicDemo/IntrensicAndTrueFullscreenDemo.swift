//
//  IntrensicDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 7/30/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class IntrensicAndTrueFullscreenDemo: Demoable {
    var name: String {
        return "Intrensic And True Fullscreen"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        let controller = IntrinsicExampleViewController.instantiate()
        return SheetViewController(controller: controller, sizes: [.intrinsic, .fullscreen], options: SheetOptions(useInlineMode: useInlineMode))
    }
}
