//
//  ScrollViewExampleViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 2/1/19.
//  Copyright © 2019 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class ScrollViewExampleViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sheetViewController?.handleScrollView(self.scrollView)
    }
    
    static func instantiate() -> ScrollViewExampleViewController {
        return UIStoryboard(name: "ScrollExample", bundle: nil).instantiateViewController(withIdentifier: "scrollView") as! ScrollViewExampleViewController
    }
}
