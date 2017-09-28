//
//  MMPlayerView.swift
//  Pods
//
//  Created by Millman YANG on 2017/6/20.
//
//


import UIKit
import AVFoundation

public class MMPlayerView: UIView {
    fileprivate unowned let playerLayer: MMPlayerLayer
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.playerLayer = MMPlayerLayer()
        super.init(coder: aDecoder)
        self.setup()
    }
    
    public override init(frame: CGRect) {
        self.playerLayer = MMPlayerLayer()
        super.init(frame: frame)
        self.setup()
    }
    
    fileprivate func setup() {
        self.playerLayer.playView = self
    }
    
    public var playUrl: URL? {
        set {
            self.playerLayer.playUrl = newValue
        } get {
            return self.playerLayer.playUrl
        }
    }
    
    public weak var delegate: MMPlayerLayerProtocol? {
        set {
            self.playerLayer.mmDelegate = newValue
        } get {
            return self.playerLayer.mmDelegate
        }
    }
    
    public var progressType: ProgressType {
        set {
            self.playerLayer.progressType = newValue
        } get {
            return self.playerLayer.progressType
        }
    }
    
    public var coverFitType: CoverViewFitType {
        set {
            self.playerLayer.coverFitType = newValue
        } get {
            return self.playerLayer.coverFitType
        }
    }
    
    public var autoHideCoverType: MMPlayerCoverAutoHideType {
        set {
            self.playerLayer.autoHideCoverType = newValue
        } get {
            return self.playerLayer.autoHideCoverType
        }
    }
    public var videoGravity: AVLayerVideoGravity {
        set {
            self.playerLayer.videoGravity = newValue
        } get {
            return self.playerLayer.videoGravity
        }
    }
    public var thumbImage: UIImage? {
        set {
            self.playerLayer.thumbImageView.image = newValue
        } get {
            return self.playerLayer.thumbImageView.image
        }
    }
    
    public var autoPlay: Bool {
        set {
            self.playerLayer.autoPlay = newValue
        } get {
            return self.playerLayer.autoPlay
        }
    }
    
    public var cacheType: MMPlayerCacheType {
        set {
            self.playerLayer.cacheType = newValue
        } get {
            return self.playerLayer.cacheType
        }
    }
    
    public func delayHideCover () {
        self.playerLayer.delayHideCover()
    }

    public func replace<T: UIView>(cover: T) where T: MMPlayerCoverViewProtocol {
        self.playerLayer.replace(cover: cover)
    }
    
    public func set(url: URL?, state: ((_ status: MMPlayerPlayStatus) -> Void)?) {
        self.playerLayer.set(url: url, state: state)
    }
    
    public func set(url: URL?, thumbImage: UIImage, state: ((_ status: MMPlayerPlayStatus) -> Void)?) {
        self.playerLayer.thumbImageView.image = thumbImage
        self.playerLayer.set(url: url, state: state)
    }
    
    public func showCover(isShow: Bool) {
        self.playerLayer.showCover(isShow: isShow)
    }
    
    public func startLoading() {
        self.playerLayer.startLoading()
    }

    public func set(progress: ProgressType) {
        self.playerLayer.progressType = progress
    }
    
    public var player: AVPlayer? {
        return self.playerLayer.player
    }
    
    deinit {
        self.playerLayer.removeAllObserver()
    }
}
