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
    internal var config: MMPlayerPresentConfig!

    convenience init(config: MMPlayerPresentConfig , isPresent: Bool) {
        self.init()
        self.config = config
        self.isPresent = isPresent
    }
}

public class MMPlayerBaseNavTransition: NSObject {
    var operation:UINavigationControllerOperation = .none
    internal var config: MMPlayerConfig!
    
    convenience init(config: MMPlayerConfig , operation: UINavigationControllerOperation) {
        self.init()
        self.config = config
        self.operation = operation
    }    
}

