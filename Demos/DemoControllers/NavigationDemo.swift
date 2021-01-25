//
//  NavigationRootViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class NavigationDemo: UIViewController, Demoable {
    static var name: String { "Navigation controller" }
    
    var exampleViewController: UIViewController!
    
    @IBAction func navigateToChildTapped(_ sender: Any) {
        self.navigationController?.pushViewController(exampleViewController, animated: true)
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
        
        let controller2 = UIStoryboard(name: "KeyboardDemo", bundle: nil).instantiateInitialViewController()!
        
        let controller = UIStoryboard(name: "NavigationDemo", bundle: nil).instantiateInitialViewController() as! NavigationDemo
        controller.exampleViewController = controller2
        
        let nav = UINavigationController(rootViewController: controller)
        
        let sheet = SheetViewController(
            controller: nav,
            sizes: [.intrinsic, .percent(0.5), .fullscreen],
            options: SheetOptions(useInlineMode: useInlineMode))
        
        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
