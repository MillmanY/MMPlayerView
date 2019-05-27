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
    
    var cacheCount = 20
    private var cache = [URL : AVPlayerItem]()
    private var queueURL = [URL]()
    
    func appendCache(key: URL , item: AVPlayerItem) {
        if cache.keys.count >= cacheCount {
            if let f = queueURL.first {
                self.removeCache(key: f)
            }
        }
        queueURL.append(key)
        cache[key] = item
    }
    
    func getItem(key: URL) -> AVPlayerItem? {
        return cache[key]
    }
    
    func removeCache(key: URL) {
        if let idx = queueURL.firstIndex(of: key) {
            queueURL.remove(at: idx)
        }
        cache.removeValue(forKey: key)
    }
    
    func removeAll() {
        queueURL.removeAll()
        cache.removeAll()
    }
}
