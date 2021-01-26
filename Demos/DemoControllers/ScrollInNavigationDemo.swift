//
//  ScrollViewExampleViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class ScrollInNavigationDemo: UIViewController, Demoable {
    static var name: String { "Scrolling In Navigation Controller" }

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sheetViewController?.handleScrollView(self.scrollView)
    }
    
    static func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil
        
        let controller = UIStoryboard(name: "ScrollInNavigationDemo", bundle: nil).instantiateInitialViewController()!
        
        let nav = UINavigationController(rootViewController: controller)
        
        let sheet = SheetViewController(
            controller: nav,
            sizes: [.percent(0.25), .fullscreen],
            options: SheetOptions(useInlineMode: useInlineMode))
        
        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
