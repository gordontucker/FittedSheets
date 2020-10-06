//
//  KeyboardDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class KeyboardDemo: Demoable {
    var name: String {
        return "Keyboard"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        let controller = UITextFieldExampleViewController.instantiate()
        
        let c = SheetViewController(controller: controller, sizes: [.percent(0.5), .fullscreen], options: SheetOptions(useInlineMode: useInlineMode))
        
        c.autoAdjustToKeyboard = false
        
        return c
    }
}
