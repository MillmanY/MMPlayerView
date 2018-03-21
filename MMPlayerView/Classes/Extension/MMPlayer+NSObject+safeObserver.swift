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
    
    public var bindObj: [UUID:[String]] {
        get {
            
            if let o = objc_getAssociatedObject(self, &bindObjKey) as? [UUID:[String]] {
                return o
            } else {
                self.bindObj = [UUID:[String]]()
                return self.bindObj
            }
            
        } set {
            objc_setAssociatedObject(self, &bindObjKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func safeAdd(observer: NSObject, forKeyPath: String, options:
        NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?) {
        if bindObj[observer.uuid] == nil {
            bindObj[observer.uuid] = [String]()
        }
        if let b = bindObj[observer.uuid], !b.contains(forKeyPath) {
            bindObj[observer.uuid]?.append(forKeyPath)
            self.addObserver(observer, forKeyPath: forKeyPath, options: options, context: context)
        }
    }
    
    public func safeRemove(observer: NSObject, forKeyPath: String) {
        if let b = bindObj[observer.uuid], let keyIdx = b.index(of: forKeyPath) {
            bindObj[observer.uuid]?.remove(at: keyIdx)
            self.removeObserver(observer, forKeyPath: forKeyPath)
        }
    }
}

var uuidKey = "uuid"
extension NSObject {
    public var uuid: UUID {
        get {
            if let o = objc_getAssociatedObject(self, &uuidKey) as? UUID {
                return o
            } else {
                objc_setAssociatedObject(self, &uuidKey, UUID(), .OBJC_ASSOCIATION_RETAIN)
                return self.uuid
            }
        }
    }
}
