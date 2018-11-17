//
//  UIApplication+Safe.swift
//  MMPlayerView
//
//  Created by Millman on 2018/11/17.
//

import Foundation

extension UIWindow {
    var realSafe: UIEdgeInsets {
        get {
            if #available(iOS 11.0, *) {
                return self.safeAreaInsets
            } else {
                return .zero
            }
        }
    }
}
