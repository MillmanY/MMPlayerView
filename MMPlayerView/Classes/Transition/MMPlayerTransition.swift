//
//  MMTransition.swift
//  Pods
//
//  Created by Millman YANG on 2017/4/24.
//
//

import UIKit

fileprivate var mmPresentKey = "MMPlayerPresentKey"
fileprivate var mmPushKey = "MMPlayerPushKey"
public extension MMPlayerTransition where T: UIViewController {
    var present: MMPlayerPresentAnimator {
        if let v = objc_getAssociatedObject(base, &mmPresentKey) {
            return v as! MMPlayerPresentAnimator
        }
        let m = MMPlayerPresentAnimator(self.base)
        objc_setAssociatedObject(base, &mmPresentKey, m, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return m
    }
}

public extension MMPlayerTransition where T: UINavigationController {
    var push: MMPlayerPushAnimator {
        if let v = objc_getAssociatedObject(base, &mmPushKey) {
            return v as! MMPlayerPushAnimator
        }
        let m = MMPlayerPushAnimator(self.base)
        objc_setAssociatedObject(base, &mmPushKey, m, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return m
    }
}
