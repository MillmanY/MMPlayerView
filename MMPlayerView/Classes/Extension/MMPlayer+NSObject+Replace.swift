//
//  MMPlayer+NSObject+Replace.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2018/3/21.
//

import Foundation
extension NSObject {
    
    static func replaceSelector(from: Selector, to: Selector) {
        
        
        guard let originalMethod = class_getInstanceMethod(self.classForCoder(), from) else {
            print("OriginalMethod nil")
            return
        }
        
        guard let swizzledMethod = class_getInstanceMethod(self.classForCoder(), to) else {
            print("SwizzleMethod nil")
            return
        }
        
        let didAddMethod = class_addMethod(self.classForCoder(), from, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(self.classForCoder(), to, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}
