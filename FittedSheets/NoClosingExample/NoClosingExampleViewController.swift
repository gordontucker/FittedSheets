//
//  NoClosingExampleViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit

class NoClosingExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    static func instantiate() -> NoClosingExampleViewController {
        return UIStoryboard(name: "NoClosing", bundle: nil).instantiateViewController(withIdentifier: "noclose") as! NoClosingExampleViewController
    }
}
