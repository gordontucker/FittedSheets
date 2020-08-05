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
        NonFullScreenMode(),
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
        
        sheet.delegate = self
        
        // Add child
        sheet.willMove(toParent: self)
        self.addChild(sheet)
        self.containerView.addSubview(sheet.view)
        sheet.didMove(toParent: self)
        Constraints(for: sheet.view) {
            $0.edges(.top, .left, .bottom, .right).pinToSuperview()
        }
        
        // animate in
        sheet.animateIn()
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

extension InlineExamplesViewController: SheetDelegate {
    func sheetViewControllerDidDismiss() {
        self.mapView?.removeFromSuperview()
        self.stackViewBottomConstraint.constant = 20
    }
    
    func sheetViewControllerChangedSize(to: CGFloat) {
        if self.mapView != nil {
            self.stackViewBottomConstraint.constant = to
        }
    }
}
