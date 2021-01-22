//
//  InlineExamplesViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/5/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class InlineExamplesViewController: UIViewController {
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var stackViewBottomConstraint: NSLayoutConstraint!
    var mapView: UIView?
    
    var demos: [Demoable] = [
        IntrensicDemo(),
        EmbededIntrensicDemo(),
        IntrensicAndFullscreenDemo(),
        IntrensicAndTrueFullscreenDemo(),
        ResizingDemo(),
        RecycledDemo(),
        NavigationDemo(),
        KeyboardDemo(),
        ScrollViewDemo(),
        ScrollInNavigationDemo(),
        TableViewDemo(),
        TableViewControllerDemo(),
        ColorDemo(),
        NoPullBarDemo(),
        ClearPullBarDemo(),
        NoCloseDemo(),
        RecursionDemo(),
        MaxMinHeightDemo(),
        HorizontalPaddingDemo(),
        MaxWidthDemo()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addButton(demo: MapDemo()) { [weak self] in
            self?.addMapView()
        }
        
        for demo in demos {
            self.addButton(demo: demo)
        }
    }
    
    func addButton(demo: Demoable, onTap: (() -> Void)? = nil) {
        let button = UIButton()
        button.setTitle(demo.name, for: .normal)
        if #available(iOS 13.0, *) {
            button.setTitleColor(.label, for: .normal)
        } else {
            button.setTitleColor(UIColor.darkText, for: .normal)
        }
        button.onTap { [weak self] in
            onTap?()
            self?.presentDemo(demo)
        }
        self.stackView.addArrangedSubview(button)
    }
    
    func presentDemo(_ demo: Demoable) {
        let sheet = demo.buildDemo(useInlineMode: true)
        
        sheet.didDismiss = { [weak self] _ in
            print("did dismiss")
            self?.mapView?.removeFromSuperview()
            self?.stackViewBottomConstraint.constant = 20
        }
        
        sheet.shouldDismiss = { _ in
            print("should dismiss")
            return true
        }
        
        // animate in
        sheet.animateIn(to: self.containerView, in: self)
    }
    
    func addMapView() {
        let view = UIScrollView()
        let imageView = UIImageView()
        view.addSubview(imageView)
        imageView.image = UIImage(named: "map")
        imageView.contentMode = .scaleAspectFill
        Constraints(for: imageView) {
            $0.size.height.set(UIScreen.main.bounds.size.height)
            $0.size.width.set(UIScreen.main.bounds.size.width * 2)
            $0.edges.pinToSuperview()
        }
        
        self.containerView.addSubview(view)
        Constraints(for: view) {
            $0.edges.pinToSuperview()
        }
        self.mapView = view
    }
}
