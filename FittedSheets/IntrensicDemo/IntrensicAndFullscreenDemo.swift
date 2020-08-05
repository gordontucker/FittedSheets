//
//  IntrensicDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 7/30/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class IntrensicAndFullscreenDemo: Demoable {
    var name: String {
        return "Intrensic And Fullscreen"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        let controller = IntrinsicExampleViewController.instantiate()
        let options = SheetOptions(
            useFullScreenMode: false,
            useInlineMode: useInlineMode,
            minimumSpaceAbovePullBar: 44)
        return SheetViewController(controller: controller, sizes: [.intrensic, .fullscreen], options: options)
    }
}
