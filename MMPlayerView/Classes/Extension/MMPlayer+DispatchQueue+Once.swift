//
//  MMPlayer+DispatchQueue+Once.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2018/3/21.
//

import Foundation
public extension DispatchQueue {
    private static var _onceTokens = [String]()
    public class func once(token: String, block:(()->Void)) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTokens.contains(token) {
            return
        }
        _onceTokens.append(token)
        block()
    }
    
    public class func clear(token: String) {
        if let index = _onceTokens.index(of: token) {
            _onceTokens.remove(at: index)
        }
    }
}
