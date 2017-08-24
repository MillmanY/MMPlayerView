//
//  NSObject+safeObserver.swift
//  Pods
//
//  Created by Millman YANG on 2017/8/22.
//
//

import Foundation

var bindObjKey = "ObserverBindKey"
public extension NSObject {
    public var bindObj: [Int:[String]] {
        get {
            
            if let o = objc_getAssociatedObject(self, &bindObjKey) as? [Int:[String]] {
                return o
            } else {
                self.bindObj = [Int:[String]]()
                return self.bindObj
            }
            
        } set {
            objc_setAssociatedObject(self, &bindObjKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func safeAdd(observer: NSObject, forKeyPath: String, options:
        NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?) {
        
        if bindObj[observer.hashValue] == nil {
            bindObj[observer.hashValue] = [String]()
        }
        
        if let b = bindObj[observer.hashValue], !b.contains(forKeyPath) {
            bindObj[observer.hashValue]?.append(forKeyPath)
            self.addObserver(observer, forKeyPath: forKeyPath, options: options, context: context)
        }
    }
    
    public func safeRemove(observer: NSObject, forKeyPath: String) {
        if let b = bindObj[observer.hashValue], let keyIdx = b.index(of: forKeyPath) {
            bindObj[observer.hashValue]?.remove(at: keyIdx)
            self.removeObserver(observer, forKeyPath: forKeyPath)
        }
    }
}
