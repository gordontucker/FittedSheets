//
//  SheetView.swift
//  FittedSheetsPod
//
//  Created by Gordon Tucker on 8/5/20.
//  Copyright © 2020 Gordon Tucker. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit

class SheetView: UIView {

    weak var delegate: SheetViewDelegate?
    weak var viewToTranslateGesture: UIView?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if self.delegate?.sheetPoint(inside: point, with: event) ?? true {
            return view
        } else {
            // Pass gesture to parentController 
            return viewToTranslateGesture?.hitTest(point, with: event)
        }
    }

}

#endif // os(iOS) || os(tvOS) || os(watchOS)
