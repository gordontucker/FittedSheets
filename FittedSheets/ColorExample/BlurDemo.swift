//
//  BlurDemo.swift
//  FittedSheets
//
//  Created by farhad jebelli on 8/13/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class BlurDemo: Demoable {
    var name: String {
        return "Blur Effect"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        let controller = UIStoryboard(name: "ColorExample", bundle: nil).instantiateViewController(withIdentifier: "customize")
        
        var options = SheetOptions()
        options.pullBarHeight = 30
        options.useInlineMode = useInlineMode
        
        let sheet = SheetViewController(controller: controller, sizes: [.percent(0.25), .fullscreen], options: options)
        sheet.hasBlurBackground = true
        
        sheet.cornerRadius = 30
        sheet.gripSize = CGSize(width: 100, height: 12)
        return sheet
    }
}
