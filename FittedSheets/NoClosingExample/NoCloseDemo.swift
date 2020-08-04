//
//  NoCloseDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class NoCloseDemo: Demoable {
    var name: String {
        return "Keyboard"
    }
    
    func buildDemo() -> SheetViewController {
        let controller = NoClosingExampleViewController.instantiate()
        
        let sheet = SheetViewController(controller: controller, sizes: [.percent(0.5), .fullscreen])
        sheet.dismissOnPull = false
        sheet.dismissOnOverlayTap = false
        return sheet
    }
}
