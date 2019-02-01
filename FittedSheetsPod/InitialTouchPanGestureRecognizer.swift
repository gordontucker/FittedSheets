//
//  InitialTouchPanGestureRecognizer.swift
//  FittedSheets
//
//  Created by Gordon Tucker on 8/27/18.
//  Copyright © 2018 Gordon Tucker. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

class InitialTouchPanGestureRecognizer: UIPanGestureRecognizer {
    var initialTouchLocation: CGPoint?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        initialTouchLocation = touches.first?.location(in: view)
    }
}
