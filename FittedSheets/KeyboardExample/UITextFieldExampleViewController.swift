//
//  UITextFieldExampleViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit

class UITextFieldExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    static func instantiate() -> UITextFieldExampleViewController {
        return UIStoryboard(name: "KeyboardExample", bundle: nil).instantiateViewController(withIdentifier: "text-field") as! UITextFieldExampleViewController
    }
}
