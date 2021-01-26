//
//  EmbededIntrinsicDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 7/30/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class IntrinsicInNavigationDemo: UIViewController, Demoable {
    static var name: String { "Intrinsic height in navigation controller" }
    
    static func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil
        
        let controller = UIStoryboard(name: "IntrinsicInNavigationDemo", bundle: nil).instantiateInitialViewController()!
        
        let nav = UINavigationController(rootViewController: controller)
        
        let sheet = SheetViewController(
            controller: nav,
            options: SheetOptions(useInlineMode: useInlineMode))
        
        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
