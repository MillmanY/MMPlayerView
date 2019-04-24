//
//  MMPlayer+DispatchQueue+Once.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2018/3/21.
//

import Foundation
public extension DispatchQueue {
    private static var _onceTokens = [String]()
    class func once(token: String, block:(()->Void)) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTokens.contains(token) {
            return
        }
        _onceTokens.append(token)
        block()
    }
    
    class func clear(token: String) {
        if let index = _onceTokens.firstIndex(of: token) {
            _onceTokens.remove(at: index)
        }
    }
}
