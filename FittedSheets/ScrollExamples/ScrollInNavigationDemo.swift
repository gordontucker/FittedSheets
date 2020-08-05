//
//  ScrollViewDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class ScrollInNavigationDemo: Demoable {
    var name: String {
        return "Scroll View In Navigation"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        let controller = ScrollViewExampleViewController.instantiate()
        
        let nav = UINavigationController(rootViewController: controller)
        return SheetViewController(controller: nav, sizes: [.percent(0.25), .fullscreen], options: SheetOptions(useInlineMode: useInlineMode))
    }
}
