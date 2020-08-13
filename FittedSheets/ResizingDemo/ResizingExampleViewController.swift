//
//  SelfSizingExampleViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class ResizingExampleViewController: UIViewController {

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
    
    static func instantiate() -> ResizingExampleViewController {
        return UIStoryboard(name: "ResizingDemo", bundle: nil).instantiateViewController(withIdentifier: "resizing") as! ResizingExampleViewController
    }
}
