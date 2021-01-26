//
//  TableViewDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class NoPullBarDemo: SimpleDemo {
    override class var name: String { "No Pull Bar" }

    override class func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil
        
        let controller = ColorDemo()
        
        var options = SheetOptions()
        options.pullBarHeight = 0
        options.useInlineMode = useInlineMode
        
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.percent(0.25), .fullscreen],
            options: options)
        sheet.cornerRadius = 4
        sheet.allowPullingPastMaxHeight = false
        sheet.overlayColor = .clear
        sheet.contentViewController.view.layer.shadowColor = UIColor.black.cgColor
        sheet.contentViewController.view.layer.shadowOpacity = 0.06
        sheet.contentViewController.view.layer.shadowRadius = 10
        
        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
