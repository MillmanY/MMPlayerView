//
//  BaseTransition.swift
//  Pods
//
//  Created by Millman YANG on 2017/3/27.
//
//

import UIKit

public class BasePresentTransition: NSObject {
    var isPresent = true
    var source: UIViewController?
    internal var config: Config!

    convenience init(config: Config , isPresent: Bool) {
        self.init()
        self.config = config
        self.isPresent = isPresent
    }

}


public class BaseNavTransition: NSObject {
    var operation:UINavigationControllerOperation = .none
    var source: UIViewController?
    internal var config:Config!
    
    convenience init(config: Config , operation: UINavigationControllerOperation) {
        self.init()
        self.config = config
        self.operation = operation
    }    
}

