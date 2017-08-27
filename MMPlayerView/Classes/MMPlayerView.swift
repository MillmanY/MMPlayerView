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
    
    public var hideCoverDuration: TimeInterval {
        set {
            self.playerLayer.hideCoverDuration = newValue
        } get {
            return self.playerLayer.hideCoverDuration
        }
    }
    
    public var videoGravity: String {
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
    
    public var autoLoadUrl: Bool {
        set {
            self.playerLayer.autoLoadUrl = newValue
        } get {
            return self.playerLayer.autoLoadUrl
        }
    }
    
    public var cacheInMemory: Bool {
        set {
            self.playerLayer.cacheInMemory = newValue
        } get {
            return self.playerLayer.cacheInMemory
        }
    }

    public var asset: AVURLAsset? {
        get {
            return self.playerLayer.asset
        }
    }
    
    public func delayHideCover () {
        self.playerLayer.delayHideCover()
    }

    public func replace<T: UIView>(cover: T) where T: CoverViewProtocol {
        self.playerLayer.replace(cover: cover)
    }
    
    public func set(url: URL?, state: ((_ status: PlayViewPlayStatus) -> Void)?) {
        self.playerLayer.set(url: url, state: state)
    }
    
    public func set(url: URL?, thumbImage: UIImage, state: ((_ status: PlayViewPlayStatus) -> Void)?) {
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
