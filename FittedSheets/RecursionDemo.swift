//
//  RecursionDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/5/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class RecursionDemo: Demoable {
    var name: String {
        return "Rescursion!"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        var options = SheetOptions()
        options.useInlineMode = useInlineMode
        options.useFullScreenMode = false
        let sheet = SheetViewController(controller: controller, sizes: [.percent(0.50), .fullscreen], options: options)
        
        return sheet
    }
}
