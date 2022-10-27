//
//  RootViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 7/30/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit

class ModalDemosViewController: UIViewController {

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var scrollView: UIScrollView!
    
    var demos: [(UIViewController & Demoable).Type] = [
        OnlyCloseWithButtonDemo.self,
        ResizingDemo.self,
        NavigationDemo.self,
        ScrollViewDemo.self,
        TableViewDemo.self,
        TableViewControllerDemo.self,
        ScrollInNavigationDemo.self,
        KeyboardDemo.self,
        IntrinsicDemo.self,
        IntrinsicInNavigationDemo.self,
        IntrinsicAndFullscreenDemo.self,
        IntrinsicAndTrueFullscreenDemo.self,
        ColorDemo.self,
        NoPullBarDemo.self,
        ClearPullBarDemo.self,
        MaxMinHeightDemo.self,
        HorizontalPaddingDemo.self,
        MaxWidthDemo.self,
        BlurDemo.self,
        NestedSheetsDemo.self,
        RubberBandDemo.self,
        CornerCurveDemo.self
    ].sorted(by: { $0.name < $1.name })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for demo in demos {
            self.addButton(for: demo)
        }
        
        self.sheetViewController?.handleScrollView(self.scrollView)
    }
    
    func addButton(for demo: (UIViewController & Demoable).Type) {
        let button = UIButton(type: .system)
        
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
        }
        self.stackView.addArrangedSubview(button)
    }
}
