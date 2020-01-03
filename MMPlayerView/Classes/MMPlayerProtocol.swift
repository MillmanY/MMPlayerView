//
//  CoverViewProtocol.swift
//  Pods
//
//  Created by Millman YANG on 2017/6/20.
//
//

import Foundation
import AVFoundation
@objc public protocol MMPlayerBasePlayerProtocol: class {
    weak var playLayer: MMPlayerLayer? { set get }
    @objc optional func player(isMuted: Bool)
    
    @objc optional func timerObserver(time: CMTime)
    @objc optional func coverView(isShow: Bool)
    @objc optional func removeObserver()
    @objc optional func addObserver()
}

public protocol MMPlayerCoverViewProtocol: MMPlayerBasePlayerProtocol {
    func currentPlayer(status: MMPlayerDefine.PlayStatus)
}

public protocol MMProgressProtocol {
    func start()
    func stop()
}

public protocol MMPlayerLayerProtocol: class {
    func touchInVideoRect(contain: Bool)
}

public protocol ConverterProtocol {
    associatedtype Element
    func parseText(_ value: String)
    func search(duration: TimeInterval, completed: @escaping (([Element])->Void))
}


let VideoBasePath = NSTemporaryDirectory()

public struct MMPlayerDefine {
    static let assetKeysRequiredToPlay = [
    "duration",
    "playable",
    "hasProtectedContent",
    ]

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
    
    public enum PlayerCacheType {
        case none
        case memory(count: Int)
    }
}
