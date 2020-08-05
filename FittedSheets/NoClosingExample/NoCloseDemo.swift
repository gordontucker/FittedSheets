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
    var name: String = "Non Closing"
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        let controller = NoClosingExampleViewController.instantiate()
        
        let sheet = SheetViewController(controller: controller, sizes: [.percent(0.5), .fullscreen], options: SheetOptions(useInlineMode: useInlineMode))
        sheet.dismissOnPull = false
        sheet.dismissOnOverlayTap = false
        return sheet
    }
}
