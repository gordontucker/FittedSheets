//
//  SelfResizingViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 11/29/18.
//  Copyright © 2018 Gordon Tucker. All rights reserved.
//

import UIKit

class SelfResizingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func resizeTo150(sender: Any) {
        self.sheetViewController?.resize(to: .fixed(150))
    }
    
    @IBAction func resizeTo300(sender: Any) {
        self.sheetViewController?.resize(to: .fixed(300))
    }
    
    @IBAction func resizeTo450(sender: Any) {
        self.sheetViewController?.resize(to: .fixed(450))
    }
}
