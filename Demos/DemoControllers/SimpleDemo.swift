//
//  FullScreenExampleViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class SimpleDemo: UIViewController, Demoable {
    class var name: String { "Simple" }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        self.view.addSubview(label) {
            $0.center.alignWithSuperview()
        }
        label.text = "Demo Text"
        label.textAlignment = .center
        label.textColor = UIColor.red
        
        self.view.layer.borderWidth = 1
        self.view.layer.borderColor = UIColor.red.cgColor
    }
    
    class func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil
        
        let controller = ColorDemo()
        
        var options = SheetOptions()
        options.useInlineMode = useInlineMode
        options.shouldExtendBackground = false
        
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.intrinsic, .percent(0.75), .fullscreen],
            options: options)
        sheet.overlayColor = UIColor(red: 0.933, green: 0.314, blue: 0.349, alpha: 0.3)
        sheet.gripColor = .purple
        sheet.pullBarBackgroundColor = .yellow
        sheet.cornerRadius = 40
        
        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
