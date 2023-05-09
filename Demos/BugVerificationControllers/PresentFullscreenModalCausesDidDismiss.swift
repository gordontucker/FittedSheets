//
//  PresentSecondModal.swift
//  Demos
//
//  Created by Andrew Breckenridge on 5/9/23.
//  Copyright © 2023 Gordon Tucker. All rights reserved.
//

import Foundation
import UIKit
import FittedSheets

class PresentFullscreenModalCausesDidDismiss: UIViewController, Demoable {
    static var name: String { "presenting a further view controller with `modalPresentationStyle` of `crossDissolve` causes incorrect `didDismiss` on the sheet" }

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            let controller2 = UIStoryboard(name: "IntrinsicAndFullscreenDemo", bundle: nil).instantiateInitialViewController()!
            controller2.modalPresentationStyle = .fullScreen // <- CAUSES UNDEFINED BEHAVIOR
            self.present(controller2, animated: true)
        }
    }

    static func openDemo(from parent: UIViewController, in view: UIView?) {
        let useInlineMode = view != nil

        let controller = PresentFullscreenModalCausesDidDismiss()

        let options = SheetOptions(
            useFullScreenMode: false,
            useInlineMode: useInlineMode)
        let sheet = SheetViewController(controller: controller, sizes: [.fullscreen, .intrinsic], options: options)
        sheet.minimumSpaceAbovePullBar = 44
        sheet.didDismiss = { _ in
            fatalError("shouldn't dismiss when you present the second view")
        }

        addSheetEventLogging(to: sheet)

        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
}

