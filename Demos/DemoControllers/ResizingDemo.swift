//
//  SelfSizingExampleViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class ResizingDemo: UIViewController, Demoable {
    static var name: String { "Resize buttons" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func resizeTo150(_ sender: Any) {
        self.sheetViewController?.resize(to: .fixed(150))
    }
    
    @IBAction func resizeTo300(_ sender: Any) {
        self.sheetViewController?.resize(to: .fixed(300))
    }
    
    @IBAction func resizeTo450(_ sender: Any) {
        self.sheetViewController?.resize(to: .fixed(450))
    }
    
    @IBAction func resizeToMargin50(_ sender: Any) {
        self.sheetViewController?.resize(to: .marginFromTop(50))
    }
    
    static func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil
        
        let controller = UIStoryboard(name: "ResizingDemo", bundle: nil).instantiateInitialViewController()!
        
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.fixed(200), .fixed(300), .fixed(450), .marginFromTop(50)],
            options: SheetOptions(useInlineMode: useInlineMode))
        
        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}
