//
//  ColorDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class ColorDemo: Demoable {
    var name: String {
        return "Colors"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        let controller = ColorExampleViewController.instantiate()
        var options = SheetOptions()
        options.gripColor = UIColor.purple
        options.useInlineMode = useInlineMode
        let sheet = SheetViewController(controller: controller, sizes: [.intrinsic, .percent(0.75), .fullscreen], options: options)
        sheet.overlayColor = UIColor(red: 0.933, green: 0.314, blue: 0.349, alpha: 0.3)
        
        return sheet
    }
}
