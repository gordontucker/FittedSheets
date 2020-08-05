//
//  NonFullScreenMode.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class NonFullScreenMode: Demoable {
    var name: String {
        return "Non Fullscreen Mode"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        var options = SheetOptions()
        options.useFullScreenMode = false
        options.useInlineMode = useInlineMode
        let controller = IntrinsicExampleViewController.instantiate()
        return SheetViewController(controller: controller, sizes: [.intrensic, .fullscreen], options: options)
    }
}
