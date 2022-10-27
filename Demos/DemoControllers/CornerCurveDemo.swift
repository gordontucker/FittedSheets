//
//  RubberBandDemo.swift
//  Demos
//
//  Created by Leandro Linardos on 08/08/2021.
//  Copyright © 2021 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class CornerCurveDemo: SimpleDemo {
    override class var name: String { "Corner Curve" }

    override class func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil

        let controller = ColorDemo()
        
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.fixed(150), .fixed(350)],
            options: SheetOptions(useInlineMode: useInlineMode))

        if #available(iOS 13.0, *) {
            sheet.cornerCurve = .continuous
        } else {
            assertionFailure("This demo is only available on iOS 13 and higher")
        }
        
        addSheetEventLogging(to: sheet)

        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
