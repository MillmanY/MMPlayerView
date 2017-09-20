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
    func removeObserver()
    func addObserver()
}

public protocol MMPlayerCoverViewProtocol: MMPlayerBasePlayerProtocol {
    func currentPlayer(status: MMPlayerPlayStatus)
}

public enum MMPlayerCacheType {
    case none
    case memory(count: Int)
}

public enum MMPlayerPlayStatus {
    case ready
    case unknown
    case failed(err: String)
    case playing
    case pause
    case end
}

public enum CoverViewFitType {
    case fitToPlayerView
    case fitToVideoRect
}

public enum ProgressType {
    case `default`
    case none
    case custom(view: UIView & MMProgressProtocol)
}

public protocol MMProgressProtocol {
    func start()
    func stop()
}

public protocol MMPlayerLayerProtocol: class {
    func touchInVideoRect(contain: Bool)
}
