//
//  IntrinsicExampleViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit

class IntrinsicExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    static func instantiate() -> IntrinsicExampleViewController {
        return UIStoryboard(name: "SelfSizingExample", bundle: nil).instantiateViewController(withIdentifier: "intrinsic") as! IntrinsicExampleViewController
    }
}
