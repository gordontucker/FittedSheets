//
//  Localized.swift
//  FittedSheetsPod
//
//  Created by Gordon Tucker on 8/11/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit

private class FittedSheets { }
enum Localize: String {
    case dismissPresentation
    case changeSizeOfPresentation
    
    var localized: String {
        return NSLocalizedString(self.rawValue, tableName: nil, bundle: Bundle(for: FittedSheets.self), value: "", comment: "")
    }
}
