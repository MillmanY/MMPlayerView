//
//  MMPlayer+Pointer.swift
//  MMPlayerView
//
//  Created by Millman on 2018/11/17.
//

import Foundation

protocol MMPlayerPointerProtocol {
    associatedtype K: NSObject
    var unmanaged: Unmanaged<K> {get}
}

extension MMPlayerObservation: MMPlayerPointerProtocol {
    var unmanaged: Unmanaged<MMPlayerObservation> {
        get {
            return Unmanaged.passUnretained(self)
        }
    }
    
}
