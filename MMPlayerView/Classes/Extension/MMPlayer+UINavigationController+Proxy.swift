//
//  MMPlayer+UINavigationController+Proxy.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2018/3/21.
//

import Foundation
var enableCustomTransitionKey = "enableCustomTransition"
extension UINavigationController {
    
//    public var enableCustomTransition: Bool {
//        set {
//            objc_setAssociatedObject(self, &enableCustomTransitionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        } get {
//            if let value = objc_getAssociatedObject(self, &enableCustomTransitionKey) as? Bool {
//                return value
//            }
//            self.enableCustomTransition = false
//            return false
//        }
//    }
    
    static func installProxyDelegate() {
        DispatchQueue.once(token: "navigationDelegateProxy") {
            let from = #selector(setter: UINavigationController.delegate)
            let to = #selector(UINavigationController.customDelegate(_:))
            self.replaceSelector(from: from, to: to)
        }
    }
    
    @objc func customDelegate(_ delegate: UINavigationControllerDelegate?) {
        if let original = self.delegate as? NavigationDelegateProxy, delegate?.isKind(of: NavigationDelegateProxy.classForCoder()) == false {
            original.forward = delegate
        } else {
            self.customDelegate(delegate)
        }
    }
}

public class NavigationDelegateProxy: NSObject, UINavigationControllerDelegate {
    weak var parent: UINavigationControllerDelegate?
    weak var forward: UINavigationControllerDelegate?
    public init(parent: UINavigationControllerDelegate?,
                forward: UINavigationControllerDelegate?) {
        self.parent = parent
        self.forward = forward
        super.init()
    }
    
    override public func forwardingTarget(for aSelector: Selector!) -> Any? {
        if self.parent?.responds(to: aSelector) == true {
            return parent
        } else if let forward = self.forward, forward.responds(to: aSelector){
            return forward
        }
        return super.forwardingTarget(for: aSelector)
    }
    
    override public func responds(to aSelector: Selector!) -> Bool {
        if self.parent?.responds(to: aSelector) == true {
            return true
        } else if let forward = self.forward {
            return forward.responds(to: aSelector)
        }
        return super.responds(to: aSelector)
    }
}
