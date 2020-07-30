//
//  IntrensicDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 7/30/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class IntrensicDemo: Demoable {
    var name: String {
        return "Intrensic Height"
    }
    
    func buildDemo() -> SheetViewController {
        let controller = IntrinsicExampleViewController.instantiate()
        return SheetViewController(controller: controller)
    }
}
