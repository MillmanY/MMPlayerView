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
    func currentPlayer(status: MMPlayerLayer.PlayStatus)
}

public protocol MMProgressProtocol {
    func start()
    func stop()
}

public protocol MMPlayerLayerProtocol: class {
    func touchInVideoRect(contain: Bool)
}

let VideoBasePath = NSTemporaryDirectory()
