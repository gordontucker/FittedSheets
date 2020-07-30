//
//  NavigationRootViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit

class NavigationRootViewController: UIViewController {
    var exampleViewController: UIViewController!
    
    @IBAction func navigateToChildTapped(_ sender: Any) {
        self.navigationController?.pushViewController(exampleViewController, animated: true)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            print("Closing sheet with toolbar button complete")
        }
    }
    
    static func instantiate(exampleViewController: UIViewController) -> NavigationRootViewController {
        let controller = UIStoryboard(name: "NavigationDemo", bundle: nil).instantiateViewController(withIdentifier: "root") as! NavigationRootViewController
        controller.exampleViewController = exampleViewController
        return controller
    }
}
