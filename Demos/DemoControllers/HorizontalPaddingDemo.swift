//
//  HorizontalPaddingDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 1/4/21.
//  Copyright © 2021 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class HorizontalPaddingDemo: SimpleDemo {
    override class var name: String { "Horizontal Padding" }
    
    override class func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil
        
        let controller = ColorDemo()
        
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.fixed(150), .fixed(350)],
            options: SheetOptions(useInlineMode: useInlineMode, horizontalPadding: 20))
        
        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
