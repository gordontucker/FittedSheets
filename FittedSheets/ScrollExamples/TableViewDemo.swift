//
//  TableViewDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class TableViewDemo: Demoable {
    var name: String {
        return "Table View"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        let controller = TableViewExampleViewController.instantiate()
        
        return SheetViewController(controller: controller, sizes: [.percent(0.25), .fullscreen], options: SheetOptions(useInlineMode: useInlineMode))
    }
}
