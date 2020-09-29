//
//  SafeAreaInlineExampleViewController.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 9/29/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class SafeAreaInlineExampleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func showSheetTapped(_ sender: Any) {
        let viewController = ColorExampleViewController.instantiate()
        
        let options = SheetOptions(
            pullBarHeight: 24,
            presentingViewCornerRadius: 16,
            useFullScreenMode: true,
            useInlineMode: true
        )

        let bottomSheet = SheetViewController(
            controller: viewController,
            sizes: [
                .percent(0.8),
                .percent(0.88)
            ],
            options: options
        )

        bottomSheet.willMove(toParent: self)
        self.addChild(bottomSheet)
        view.addSubview(bottomSheet.view)
        bottomSheet.didMove(toParent: self)

        // Auto layout
        bottomSheet.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                bottomSheet.view.topAnchor.constraint(equalTo: view.topAnchor),
                bottomSheet.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                bottomSheet.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                bottomSheet.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // The size of the grip in the pull bar
        bottomSheet.gripSize = CGSize(width: 29, height: 3)

        // The color of the grip on the pull bar
        bottomSheet.gripColor = UIColor(
            red: 199/255,
            green: 199/255,
            blue: 204/255,
            alpha: 1
        )

        // Disable the dismiss on background tap functionality
        bottomSheet.dismissOnOverlayTap = false

        // Disable the ability to pull down to dismiss the modal
        bottomSheet.dismissOnPull = false

        // Change the overlay color
        bottomSheet.overlayColor = .clear

        //
        bottomSheet.allowGestureThroughOverlay = true

        //
        bottomSheet.allowPullingPastMinHeight = false

        // animate in
        bottomSheet.animateIn()
    }
}
