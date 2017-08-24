//
//  MMPushAnimator.swift
//  Pods
//
//  Created by Millman YANG on 2017/4/25.
//
//

import UIKit

public typealias T = NavConfig
public class MMPushAnimator: NSObject , UINavigationControllerDelegate {
    public var config:T?
    unowned let base:UIViewController
    var transition: UIViewControllerAnimatedTransitioning?
    public init(_ base: UIViewController) {
        self.base = base
        super.init()
    }
    
    public func pass<T: PassViewPushConfig>(setting: (_ config: T)->Void) {
        self.config = PassViewPushConfig()
        self.base.navigationController?.lastDelegate = self
        base.navigationController?.delegate = self
        self.transition = nil
        setting(self.config! as! T)
    }
    
    public func removeAnimate() {
        self.config = nil
        self.transition = nil
        self.base.navigationController?.lastDelegate = nil
        base.navigationController?.delegate = nil
    }
    
    public var enableCustomTransition: Bool = false {
        didSet {
            if enableCustomTransition {
                base.navigationController?.delegate = self.base.navigationController?.lastDelegate
            } else {
                base.navigationController?.delegate = nil
            }
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController,
                                     animationControllerFor operation: UINavigationControllerOperation,
                                     from fromVC: UIViewController,
                                     to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let t = self.transition as? BaseNavTransition {
            t.operation = operation
        } else {
            let t = PassViewPushTransition(config: config!, operation: operation)
            t.source = self.base
            transition = t
        }
        return transition
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}
