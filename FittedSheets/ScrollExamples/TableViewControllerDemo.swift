//
//  TableViewDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class TableViewControllerDemo: Demoable {
    var name: String {
        return "Table View Controller"
    }
    
    func buildDemo() -> SheetViewController {
        let controller = ExampleTableViewController.instantiate()
        
        return SheetViewController(controller: controller, sizes: [.percent(0.25), .fullscreen])
    }
}
