//
//  ViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/16/18.
//  Copyright © 2018 Gordon Tucker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func presentSheet1(_ sender: Any) {
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet1"))
        
        controller.modalPresentationStyle = .overCurrentContext
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func presentSheet2(_ sender: Any) {
        
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet2"))
        
        controller.modalPresentationStyle = .overCurrentContext
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func presentSheet3(_ sender: Any) {
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet3"), sizes: [.fullScreen, .fixed(200)])
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func presentSheet3v2(_ sender: Any) {
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet3"), sizes: [.fixed(100)])
        controller.modalPresentationStyle = .overCurrentContext
        self.present(controller, animated: false, completion: nil)
    }
}

