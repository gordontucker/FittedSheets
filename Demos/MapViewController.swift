//
//  MapViewController.swift
//  Demos
//
//  Created by Gordon Tucker on 1/25/21.
//  Copyright © 2021 Gordon Tucker. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var showSheetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showSheetButton.layer.cornerRadius = 22
        showSheetButton.layer.masksToBounds = true
    }
    
    @IBAction func showSheetTapped(_ sender: Any) {
        MapDemo.openDemo(from: self, in: self.view)
    }
}
