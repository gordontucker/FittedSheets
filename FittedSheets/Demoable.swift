//
//  Demoable.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 7/30/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import UIKit
import FittedSheetsPod

protocol Demoable {
    var name: String { get }
    func buildDemo() -> SheetViewController
}
