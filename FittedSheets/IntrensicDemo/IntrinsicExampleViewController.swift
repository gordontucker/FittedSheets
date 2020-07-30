//
//  IntrinsicExampleViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class IntrinsicExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    static func instantiate() -> UIViewController {
        return UIStoryboard(name: "IntrensicDemo", bundle: nil).instantiateViewController(withIdentifier: "intrinsic")
    }
}
