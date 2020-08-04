//
//  ScrollViewDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class ScrollViewDemo: Demoable {
    var name: String {
        return "Scroll View"
    }
    
    func buildDemo() -> SheetViewController {
        let controller = ScrollViewExampleViewController.instantiate()
        
        return SheetViewController(controller: controller, sizes: [.percent(0.25), .fullscreen])
    }
}
