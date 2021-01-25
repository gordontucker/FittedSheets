//
//  TableViewDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class NestedSheetsDemo: UIViewController, Demoable {
    class var name: String { "Nested Sheets" }

    class func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        
        var options = SheetOptions()
        options.useInlineMode = useInlineMode
        options.useFullScreenMode = false
        options.transitionOverflowType = .color(color: .blue)
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.percent(0.50), .fullscreen],
            options: options)
        
        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
