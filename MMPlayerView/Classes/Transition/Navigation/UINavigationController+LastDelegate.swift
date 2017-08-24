//
//  UINavigationController+LastDelegate.swift
//  ETNews
//
//  Created by Millman YANG on 2017/6/14.
//  Copyright © 2017年 ETtoday Sen. All rights reserved.
//

import Foundation

var LastDelegateKey = "UINavigationContrllerLastDelegateKey"
extension UINavigationController {
    var lastDelegate: UINavigationControllerDelegate? {
        set {
            objc_setAssociatedObject(self, &LastDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        } get {
            
            guard let last = objc_getAssociatedObject(self, &LastDelegateKey) as? UINavigationControllerDelegate else {
                return nil
            }
            return last
        }
    }
}
