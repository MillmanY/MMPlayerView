//
//  MMTransition.swift
//  Pods
//
//  Created by Millman YANG on 2017/4/24.
//
//

import UIKit

fileprivate var mmPresentKey = "MMPresentKey"
fileprivate var mmPushKey = "MMPushKey"
public extension MMTransition where T: UIViewController {
    var present: MMPresentAnimator {
        if let v = objc_getAssociatedObject(base, &mmPresentKey) {
            return v as! MMPresentAnimator
        }
        let m = MMPresentAnimator(self.base)
        objc_setAssociatedObject(base, &mmPresentKey, m, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return m
    }
    
    var push: MMPushAnimator {
        if let v = objc_getAssociatedObject(base, &mmPushKey) {
            return v as! MMPushAnimator
        }
        let m = MMPushAnimator(self.base)
        objc_setAssociatedObject(base, &mmPushKey, m, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return m
    }    
}
