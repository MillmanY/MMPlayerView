//
//  MMPlayerCache.swift
//  Pods
//
//  Created by Millman YANG on 2017/6/20.
//
//

import UIKit
import AVFoundation
class MMPlayerCache: NSObject {
    
    static let shared = MMPlayerCache()
    
    var cacheCount = 20
    fileprivate var cache = [URL : AVPlayerItem]()
    
    func appendCache(key: URL , item: AVPlayerItem) {
        if cache.keys.count >= 20 {
            if let url = cache.first?.key {
                cache.removeValue(forKey: url)
            }
        }
        cache[key] = item
    }
    
    func getItem(key: URL) -> AVPlayerItem? {
        return cache[key]
    }
    
    func removeCache(key: URL) {
        cache.removeValue(forKey: key)
    }
    
    func removeAll() {
        cache.removeAll()
    }
}
