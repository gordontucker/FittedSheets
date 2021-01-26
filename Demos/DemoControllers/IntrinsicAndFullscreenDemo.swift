//
//  IntrinsicDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 7/30/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class IntrinsicAndFullscreenDemo: UIViewController, Demoable {
    static var name: String { "Intrinsic And Fullscreen" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    static func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil
        
        let controller = UIStoryboard(name: "IntrinsicAndFullscreenDemo", bundle: nil).instantiateInitialViewController()!
        
        let options = SheetOptions(
            useFullScreenMode: false,
            useInlineMode: useInlineMode)
        let sheet = SheetViewController(controller: controller, sizes: [.fullscreen, .intrinsic], options: options)
        sheet.minimumSpaceAbovePullBar = 44
        
        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
