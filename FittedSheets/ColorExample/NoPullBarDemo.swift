//
//  TableViewDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class NoPullBarDemo: Demoable {
    var name: String {
        return "No Pull Bar"
    }
    
    func buildDemo() -> SheetViewController {
        let controller = UIStoryboard(name: "ColorExample", bundle: nil).instantiateViewController(withIdentifier: "customize")
        
        var options = SheetOptions()
        options.cornerRadius = 4
        options.pullBarHeight = 0
        
        let sheet = SheetViewController(controller: controller, sizes: [.percent(0.25), .fullscreen], options: options)
        
        sheet.allowPullingPastMaxHeight = false
        sheet.overlayColor = .clear
        sheet.contentViewController.view.layer.shadowColor = UIColor.black.cgColor
        sheet.contentViewController.view.layer.shadowOpacity = 0.06
        sheet.contentViewController.view.layer.shadowRadius = 10
        
        return sheet
    }
}
