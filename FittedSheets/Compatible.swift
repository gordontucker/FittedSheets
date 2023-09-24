//
//  File.swift
//
//
//  Created by Nhuan Vu on 8/25/21.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit

extension UIView {
    public var compatibleSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }
}

extension CALayer {
    public var compatibleMaskedCorners: CACornerMask {
        get {
            if #available(iOS 11.0, *) {
                return self.maskedCorners
            } else {
                return []
            }
        }
        set {
            if #available(iOS 11.0, *) {
                self.maskedCorners = newValue
            }
        }
    }
}

extension UIViewController {
    public var compatibleAdditionalSafeAreaInsets: UIEdgeInsets {
        get {
            if #available(iOS 11.0, *) {
                return self.additionalSafeAreaInsets
            } else {
                return .zero
            }
        }
        set {
            if #available(iOS 11.0, *) {
                self.additionalSafeAreaInsets = newValue
            }
        }
    }
}

#endif // os(iOS) || os(tvOS) || os(watchOS)
