//
//  EmbededIntrensicDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 7/30/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class EmbededIntrensicDemo: Demoable {
    var name: String {
        return "Embeded Intrensic Height"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        let controller = IntrinsicExampleViewController.instantiate()
        let nav = UINavigationController(rootViewController: controller)
        return SheetViewController(controller: nav, options: SheetOptions(useInlineMode: useInlineMode))
    }
}
