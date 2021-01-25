//
//  BlurDemo.swift
//  FittedSheets
//
//  Created by farhad jebelli on 8/13/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class BlurDemo: SimpleDemo {
    override class var name: String { "Blur Effect" }
    
    override class func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil
        
        let controller = ColorDemo()
        
        var options = SheetOptions()
        options.pullBarHeight = 30
        options.useInlineMode = useInlineMode
        
        let sheet = SheetViewController(controller: controller, sizes: [.percent(0.25), .fullscreen], options: options)
        sheet.hasBlurBackground = true
        
        sheet.cornerRadius = 30
        sheet.gripSize = CGSize(width: 100, height: 12)
        
        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
