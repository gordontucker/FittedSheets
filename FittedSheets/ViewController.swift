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
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func presentSheet1(_ sender: Any) {
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet1"))
        controller.blurBottomSafeArea = false
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func presentSheet2(_ sender: Any) {
        
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet2"), sizes: [.halfScreen, .fullScreen, .fixed(250)])
        
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func presentSheet3(_ sender: Any) {
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet3"), sizes: [.fullScreen, .fixed(200)])
        controller.adjustForBottomSafeArea = true
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func presentSheet3v2(_ sender: Any) {
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet3"), sizes: [.fixed(100)])
        controller.adjustForBottomSafeArea = true
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func presentSheet4(_ sender: Any) {
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet4"), sizes: [.fixed(450), .fixed(300), .fixed(600), .fullScreen])
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func presentSheet5(_ sender: Any) {
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sheet5"), sizes: [.fixed(450), .fixed(300), .fixed(160), .fullScreen])
        self.present(controller, animated: false, completion: nil)
    }
    
    @IBAction func presentSelfSizingSheet(_ sender: Any) {
        let controller = SheetViewController(controller: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "selfsizing"), sizes: [.fullScreen])
        self.present(controller, animated: false, completion: nil)
    }
}

