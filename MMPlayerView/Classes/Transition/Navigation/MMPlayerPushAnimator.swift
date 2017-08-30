//
//  MMPushAnimator.swift
//  Pods
//
//  Created by Millman YANG on 2017/4/25.
//
//

import UIKit

public typealias T = MMPlayerNavConfig
public class MMPlayerPushAnimator: NSObject , UINavigationControllerDelegate {
    public var config:T?
    unowned let base:UIViewController
    var transition: UIViewControllerAnimatedTransitioning?
    public init(_ base: UIViewController) {
        self.base = base
        super.init()
    }
    
    public func pass<T: MMPlayerPassViewPushConfig>(setting: (_ config: T)->Void) {
        self.config = MMPlayerPassViewPushConfig()
        self.base.navigationController?.mmPlayerlastDelegate = self
        base.navigationController?.delegate = self
        self.transition = nil
        setting(self.config! as! T)
    }
    
    public func removeAnimate() {
        self.config = nil
        self.transition = nil
        self.base.navigationController?.mmPlayerlastDelegate = nil
        base.navigationController?.delegate = nil
    }
    
    public var enableCustomTransition: Bool = false {
        didSet {
            if enableCustomTransition {
                base.navigationController?.delegate = self.base.navigationController?.mmPlayerlastDelegate
            } else {
                base.navigationController?.delegate = nil
            }
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController,
                                     animationControllerFor operation: UINavigationControllerOperation,
                                     from fromVC: UIViewController,
                                     to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let t = self.transition as? MMPlayerBaseNavTransition {
            t.operation = operation
        } else {
            let t = MMPlayerPassViewPushTransition(config: config!, operation: operation)
            t.source = self.base
            transition = t
        }
        return transition
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}
