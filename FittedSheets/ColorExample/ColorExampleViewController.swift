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
    }
    
    static func instantiate() -> ColorExampleViewController {
        return UIStoryboard(name: "ColorExample", bundle: nil).instantiateInitialViewController() as! ColorExampleViewController
    }
}
