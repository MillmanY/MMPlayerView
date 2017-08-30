//
//  BaseTransition.swift
//  Pods
//
//  Created by Millman YANG on 2017/3/27.
//
//

import UIKit

public class MMPlayerBasePresentTransition: NSObject {
    var isPresent = true
    var source: UIViewController?
    internal var config: MMPlayerConfig!

    convenience init(config: MMPlayerConfig , isPresent: Bool) {
        self.init()
        self.config = config
        self.isPresent = isPresent
    }
}

public class MMPlayerBaseNavTransition: NSObject {
    var operation:UINavigationControllerOperation = .none
    var source: UIViewController?
    internal var config:MMPlayerConfig!
    
    convenience init(config: MMPlayerConfig , operation: UINavigationControllerOperation) {
        self.init()
        self.config = config
        self.operation = operation
    }    
}

