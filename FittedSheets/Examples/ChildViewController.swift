//
//  ChildViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 1/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit

class ChildViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
}
