//
//  ClearPullBarDemo.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/4/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

class ClearPullBarDemo: Demoable {
    var name: String {
        return "Clear Pull Bar"
    }
    
    func buildDemo(useInlineMode: Bool) -> SheetViewController {
        let controller = UIStoryboard(name: "ColorExample", bundle: nil).instantiateViewController(withIdentifier: "customize")
        
        var options = SheetOptions()
        options.pullBarHeight = 30
        options.shouldExtendBackground = false
        options.useInlineMode = useInlineMode
        options.useFullScreenMode = false
        
        let sheet = SheetViewController(controller: controller, sizes: [.percent(0.25), .fullscreen], options: options)
        
        sheet.treatPullBarAsClear = true
        sheet.minimumSpaceAbovePullBar = 20
        sheet.cornerRadius = 30
        sheet.gripSize = CGSize(width: 100, height: 12)
        return sheet
    }
}
