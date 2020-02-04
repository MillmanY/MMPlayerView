//
//  MMPlayerDefine.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/6.
//

import Foundation
import AVFoundation
public enum PlayStatus {
    case ready
    case unknown
    case failed(err: String)
    case playing
    case pause
    case end
    
    static func == (lhs: PlayStatus, rhs: PlayStatus) -> Bool {
        switch (lhs, rhs) {
        case (.ready, .ready), (.unknown, .unknown), (.playing, .playing), (.pause, .pause), (.end, .end):
            return true
        case (.failed(let l), .failed(let r)):
            return l == r
        default:
            return false
        }
    }
}

public enum PlayUIStatus: Equatable {
    case ready
    case unknown
    case failed(err: MMPlayerViewUIError)
    case playing
    case pause
    case end
    
    public static func == (lhs: PlayUIStatus, rhs: PlayUIStatus) -> Bool {
        switch (lhs, rhs) {
        case (.ready, .ready), (.unknown, .unknown), (.playing, .playing), (.pause, .pause), (.end, .end):
            return true
        case (.failed(let l), .failed(let r)):
            return l == r
        default:
            return false
        }
    }

}

public enum CoverAutoHideType {
    case autoHide(after: TimeInterval)
    case disable
    
    var delay: TimeInterval {
        get {
            switch self {
            case .autoHide(let after):
                return after
            case .disable:
                return 0
            }
        }
    }
}

public enum PlayerCacheType {
    case none
    case memory(count: Int)
}

public enum PlayerOrientation: Int {
    case landscapeLeft
    case landscapeRight
    case protrait
}

let VideoBasePath = NSTemporaryDirectory()
let sharedPlayer = AVPlayer()
let assetKeysRequiredToPlay = [
  "duration",
  "playable",
  "hasProtectedContent",
  ]
