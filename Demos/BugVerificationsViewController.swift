//
//  InlineExamplesViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/5/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheets

class BugVerificationsViewController: UIViewController {
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addButton(for: SlideInAnimationBug118ViewController.self)
    }
    
    func addButton(for demo: (UIViewController & Demoable).Type, onTap: (() -> Void)? = nil) {
        let button = UIButton()
        button.setTitle(demo.name, for: .normal)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor.black
        button.setTitleColor(UIColor.white, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        
        button.onTap { [unowned self] in
            demo.openDemo(from: self, in: nil)
            onTap?()
        }
        self.stackView.addArrangedSubview(button)
    }
}
