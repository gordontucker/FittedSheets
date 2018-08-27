//
//  SheetDockSize.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/27/18.
//  Copyright © 2018 Gordon Tucker. All rights reserved.
//

import UIKit

enum SheetSize {
    case fixed(CGFloat)
    case halfScreen
    case fullScreen
    
    var height: CGFloat {
        switch (self) {
            case .fixed(let height):
                return height
            case .fullScreen:
                let insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
                return UIScreen.main.bounds.height - max(20, insets.top) - insets.bottom
            case .halfScreen:
                let insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
                return (UIScreen.main.bounds.height - max(20, insets.top) - insets.bottom) / 2
        }
    }
}
