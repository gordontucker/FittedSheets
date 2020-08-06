// swift-tools-version:5.2
//
//  Package.swift
//  FittedSheets
//
//  Created by Andrew Breckenridge on 6/18/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "FittedSheets",
    platforms: [
        .iOS(.v10), .tvOS(.v10), .macOS(.v10_12), .watchOS(.v3)
    ],
    products: [
        .library(name: "FittedSheets", targets: ["FittedSheets"]),
    ],
    targets: [
        .target(name: "FittedSheets", path: "FittedSheetsPod"),
    ],
    swiftLanguageVersions: [.v5]
)
