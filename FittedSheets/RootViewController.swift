//
//  RootViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 7/30/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    @IBOutlet var stackView: UIStackView!
    
    var demos: [Demoable] = [
        IntrensicDemo(),
        EmbededIntrensicDemo(),
        IntrensicAndFullscreenDemo(),
        ResizingDemo(),
        NavigationDemo(),
        KeyboardDemo(),
        ScrollViewDemo(),
        ScrollInNavigationDemo(),
        TableViewDemo(),
        TableViewControllerDemo(),
        ColorDemo(),
        NoPullBarDemo(),
        ClearPullBarDemo(),
        NoCloseDemo()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for demo in demos {
            self.addButton(demo: demo)
        }
    }
    
    func addButton(demo: Demoable) {
        let button = UIButton()
        button.setTitle(demo.name, for: .normal)
        if #available(iOS 13.0, *) {
            button.setTitleColor(.label, for: .normal)
        } else {
            button.setTitleColor(UIColor.darkText, for: .normal)
        }
        button.onTap { [weak self] in
            let sheet = demo.buildDemo()
            self?.present(sheet, animated: true, completion: nil)
        }
        self.stackView.addArrangedSubview(button)
    }
}
