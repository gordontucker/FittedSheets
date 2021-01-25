//
//  IntrinsicExampleViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class IntrinsicDemo: UIViewController, Demoable {
    static var name: String { "Intrinsic Height" }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    static func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil
        
        let controller = UIStoryboard(name: "IntrinsicDemo", bundle: nil).instantiateInitialViewController()!
        
        let sheet = SheetViewController(
            controller: controller,
            options: SheetOptions(useInlineMode: useInlineMode))
        
        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
