//
//  FullScreenExampleViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit

class ColorExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sheetViewController?.overlayColor = UIColor(red: 0.933, green: 0.314, blue: 0.349, alpha: 0.3)
    }
    
    static func instantiate() -> ColorExampleViewController {
        return UIStoryboard(name: "ColorExample", bundle: nil).instantiateInitialViewController() as! ColorExampleViewController
    }
}
