//
//  IntrinsicDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 7/30/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class MapDemo: SimpleDemo {
    override class var name: String { "Map Demo" }
    
    override class func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil

        let controller = ColorDemo()

        var options = SheetOptions(useInlineMode: useInlineMode)
        options.shrinkPresentingViewController = !useInlineMode
        
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.fixed(100), .percent(0.5), .fullscreen],
            options: options)
        sheet.allowPullingPastMaxHeight = false
        sheet.allowPullingPastMinHeight = false
        
        sheet.dismissOnPull = true
        sheet.dismissOnOverlayTap = false
        sheet.overlayColor = UIColor.clear
        
        sheet.contentViewController.view.layer.shadowColor = UIColor.black.cgColor
        sheet.contentViewController.view.layer.shadowOpacity = 0.1
        sheet.contentViewController.view.layer.shadowRadius = 10
        sheet.allowGestureThroughOverlay = true

        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
