//
//  CoverViewProtocol.swift
//  Pods
//
//  Created by Millman YANG on 2017/6/20.
//
//

import Foundation
import AVFoundation
@objc public protocol BasePlayerProtocol: class {
    var playLayer: MMPlayerLayer? { set get }
    @objc optional func player(isMuted: Bool)
    
    @objc optional func timerObserver(time: CMTime)
    @objc optional func coverView(isShow: Bool)
    func removeObserver()
    func addObserver()
}

public protocol CoverViewProtocol: BasePlayerProtocol {
    func currentPlayer(status: PlayViewPlayStatus)
}

public enum PlayViewPlayStatus {
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
    case custom(view: MMProgress)
}


public protocol IndicatorProtocol {
    func setup()
    func start()
    func stop()
}

public protocol MMPlayViewProtocol: class {
    func touchInVideoRect(contain: Bool)
}

@objc public protocol CoverViewDelegate: class {
    func reloadIfNeed() -> Bool
}
