//
//  NoClosingExampleViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class OnlyCloseWithButtonDemo: UIViewController, Demoable {
    static var name: String { "Only close with button" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func closeTapped(_ sender: Any) {
        if self.sheetViewController?.options.useInlineMode == true {
            self.sheetViewController?.attemptDismiss(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    static func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil
        
        let controller = UIStoryboard(name: "OnlyCloseWithButtonDemo", bundle: nil).instantiateInitialViewController()!
        
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.percent(0.5), .fullscreen],
            options: SheetOptions(useInlineMode: useInlineMode))
        sheet.dismissOnPull = false
        sheet.dismissOnOverlayTap = false
        
        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
