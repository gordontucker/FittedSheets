//
//  MapDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/5/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class MapDemo: Demoable {
    var name: String = "Map"
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        let controller = NoClosingExampleViewController.instantiate()
        
        let sheet = SheetViewController(controller: controller, sizes: [.percent(0.5), .fullscreen], options: SheetOptions(useInlineMode: useInlineMode))
        sheet.dismissOnPull = false
        sheet.dismissOnOverlayTap = false
        sheet.overlayColor = UIColor.clear
        
        sheet.contentViewController.view.layer.shadowColor = UIColor.black.cgColor
        sheet.contentViewController.view.layer.shadowOpacity = 0.1
        sheet.contentViewController.view.layer.shadowRadius = 10
        sheet.allowGestureThroughOverlay = true
        
        return sheet
    }
}
