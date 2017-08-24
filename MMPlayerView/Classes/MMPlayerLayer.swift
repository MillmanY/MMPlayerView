//
//  MMPlayerLayer.swift
//  Pods
//
//  Created by Millman YANG on 2017/8/22.
//
//

import UIKit
import AVFoundation

public class MMPlayerLayer: AVPlayerLayer {
    
//    fileprivate var playLayer: AVPlayerLayer = {
//        let p = AVPlayerLayer()
//        p.player = AVPlayer()
//        return p
//    }()
    fileprivate var isCoverShow = false
    fileprivate var timeObserver: Any?
    fileprivate var isBackgroundPause = false
    fileprivate var _cover: CoverViewProtocol?
    fileprivate var cahce = MMPlayerCache()
    fileprivate var playStatusBlock: ((_ status: PlayViewPlayStatus) ->Void)?

    fileprivate let assetKeysRequiredToPlay = [
        "duration",
        "playable",
        "hasProtectedContent",
    ]
    fileprivate var indicator: MMProgress? {
        willSet {
            indicator?.removeFromSuperview()
        } didSet {
            if let i = indicator {
                i.isUserInteractionEnabled = true
                self.addSublayer(i.layer)
//                self.playView?.addSubview(i)
                i.setup()
            }
        }
    }
    lazy var tapGesture: UITapGestureRecognizer = {
        let g = UITapGestureRecognizer.init(target: self, action: #selector(MMPlayerLayer.touchAction(gesture:)))
        
        return g
    }()
    weak fileprivate var _playView: UIView? {
        willSet {
            coverView?.removeFromSuperview()
            indicator?.removeFromSuperview()
            _playView?.removeGestureRecognizer(tapGesture)
            _playView?.safeRemove(observer: self, forKeyPath: "frame")
            _playView?.safeRemove(observer: self, forKeyPath: "bounds")
        } didSet {
            
            _playView?.safeAdd(observer: self, forKeyPath: "frame", options: [.new,.initial], context: nil)
            _playView?.safeAdd(observer: self, forKeyPath: "bounds", options: [.new,.initial], context: nil)
            _playView?.isUserInteractionEnabled = true
            _playView?.addGestureRecognizer(tapGesture)
            _playView?.layer.insertSublayer(self, at: 0)
            self.uploadSubViewIdx()
        }
    }
    
    fileprivate func uploadSubViewIdx() {
        _playView?.addSubview(thumbImageView)
        if let c = coverView {
            _playView?.addSubview(c)
        }
        if let i = indicator {
            _playView?.addSubview(i)
            i.setup()
        }
    }
    
    public var progressType: ProgressType = .default {
        didSet {
            switch progressType {
            case .default:
                indicator = MMProgress()
            case .custom(let view):
                indicator = view
            default:
                indicator = nil
                break
            }
        }
    }
    
    public var coverFitType: CoverViewFitType = .fitToVideoRect {
        didSet {
            
            thumbImageView.contentMode = (coverFitType == .fitToVideoRect) ? .scaleAspectFit : .scaleAspectFill
            self.updateCoverConstraint()
        }
    }
    public var clearURLWhenChangeView = true
    public var hideCoverDuration: TimeInterval = 3.0
    public lazy var thumbImageView: UIImageView = {
        let t = UIImageView()
        t.clipsToBounds = true
        return t
    }()
    
    public var playView: UIView? {
        set {

            if self.playView != newValue {
                self._playView = newValue
                
                if clearURLWhenChangeView {
                   self.playUrl = nil
                }
            }
        } get {
            return _playView
        }
    }
    
    public var coverView: UIView? {
        get {
            return (_cover as? UIView)
        }
    }
    public var autoLoadUrl = true
    public var autoPlay = true
    public var currentPlayStatus: PlayViewPlayStatus = .unknown {
        didSet {
            self.thumbImageView.isHidden = true
            if let block = self.playStatusBlock {
                block(currentPlayStatus)
            }
            _cover?.currentPlayer(status: currentPlayStatus)
            
            switch self.currentPlayStatus {
            case .ready:
                self.thumbImageView.isHidden = false
                self.coverView?.isHidden = false
                if self.autoPlay {
                    self.player?.play()
                }
            case .unknown:
                self.thumbImageView.isHidden = false
                self.coverView?.isHidden = true
            default:
                self.coverView?.isHidden = false
                break
            }
        }
    }
    public var cacheInMemory = false
    public var asset:AVURLAsset?
    public var playUrl: URL? {
        willSet {
            self.currentPlayStatus = .unknown
            self.isBackgroundPause = false
            self.player?.replaceCurrentItem(with: nil)
            self.showCover(isShow: false)
            
            guard let url = newValue else {
                return
            }
            self.addPlayerObserver()
            if let cacheItem = self.cahce.getItem(key: url) , cacheItem.status == .readyToPlay{
                self.asset = (cacheItem.asset as? AVURLAsset)
                self.player?.replaceCurrentItem(with: cacheItem)
            } else {
                self.startLoading(isStart: true)
                
                self.asset = AVURLAsset(url: url)
                self.asset?.loadValuesAsynchronously(forKeys: assetKeysRequiredToPlay) { [weak self] in
                    DispatchQueue.main.async {
                        if let a = self?.asset, let keys = self?.assetKeysRequiredToPlay {
                            for key in keys {
                                var error: NSError?
                                let _ =  a.statusOfValue(forKey: key, error: &error)
                                if let e = error {
                                    self?.currentPlayStatus = .failed(err: e.localizedDescription)
                                    return
                                }
                            }
                            
                            let item = AVPlayerItem(asset: a)
                            if self?.cacheInMemory == true {
                                self?.cahce.appendCache(key: url, item: item)
                            }
                            self?.player?.replaceCurrentItem(with: item)
                        }
                    }
                }
            }
        }
    }

    public func setCoverView(enable: Bool) {
        self.tapGesture.isEnabled = enable
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init() {
        super.init()
        self.setup()
    }
    
    fileprivate func setup() {
        self.player = AVPlayer()
        self.progressType = .default
    }
    
    fileprivate func updateCoverConstraint() {
        let vRect = self.coverFitType == .fitToVideoRect ? videoRect : (playView?.bounds ?? .zero)
        if vRect.isEmpty {
            self.coverView?.isHidden = true
        } else {
            self.coverView?.isHidden = false
            self.coverView?.frame = vRect
        }
    }
    
    public func delayHideCover() {
        self.showCover(isShow: true)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MMPlayerLayer.showCover(isShow:)), object: nil)
        self.perform(#selector(MMPlayerLayer.showCover(isShow:)), with: nil, afterDelay: hideCoverDuration)
    }
    
    public func replace(cover: UIView) {
        if let c = self.coverView ,c.isKind(of: cover.classForCoder) {
            c.alpha = 1.0
            return
        }
        cover.backgroundColor = UIColor.clear
        cover.layoutIfNeeded()
        if let c = cover as? CoverViewProtocol {
            (_cover as? UIView)?.removeFromSuperview()
            _cover?.removeObserver()
            _cover = c
            _cover?.playLayer = self
            self.uploadSubViewIdx()
            c.addObserver()
            self.updateCoverConstraint()
            if let m = self.player?.isMuted {
                c.player?(isMuted: m)
            }
            c.currentPlayer(status: self.currentPlayStatus)
            
        } else {
            NSException(name: .invalidArgumentException, reason: "Cover view need implement CoverViewProtocol", userInfo: nil).raise()
        }
    }
    fileprivate var willPlayUrl: URL? {
        didSet {
            
            if oldValue != willPlayUrl {
                self.playUrl = nil
            }
            
            if autoLoadUrl {
                self.playUrl = willPlayUrl
            }
        }
    }
    public func set(url: URL?, state: ((_ status: PlayViewPlayStatus) -> Void)?) {
        self.playStatusBlock = state
        self.willPlayUrl = url
    }

    public func startLoading() {

        switch self.currentPlayStatus {
        case .playing , .pause:
            if self.playUrl == willPlayUrl {
                return
            }
        default:
            break
        }
        self.playUrl = willPlayUrl
    }
    
    fileprivate func addPlayerObserver() {
        NotificationCenter.default.removeObserver(self)
        if timeObserver == nil {
            timeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 100), queue: DispatchQueue.main, using: { [weak self] (time) in
                if let cover = self?.coverView, cover.responds(to: #selector(self?._cover?.timerObserver(time:))) {
                    if (time.isIndefinite) {
                        return
                    }
                    
                    switch self?.currentPlayStatus {
                    case .some(.playing):
                        self?._cover?.timerObserver?(time: time)
                    default: break
                    }
                }
            })
        }
        
        NotificationCenter.default.addObserver(forName: .UIApplicationWillResignActive, object: nil, queue: nil, using: { [weak self] (nitification) in
            switch self?.currentPlayStatus ?? .unknown {
            case .pause:
                self?.isBackgroundPause = true
            default:
                self?.isBackgroundPause = false
            }
            self?.player?.pause()
        })
        
        NotificationCenter.default.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil, using: { [weak self] (nitification) in
            if self?.isBackgroundPause == false {
                self?.player?.play()
            }
            self?.isBackgroundPause = false
        })
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil, using: { [weak self] (_) in
            
            if let s = self?.currentPlayStatus {
                switch s {
                case .playing, .pause:
                    if let u = self?.playUrl {
                        self?.cahce.removeCache(key: u)
                    }
                    self?.currentPlayStatus = .end
                default: break
                }
            }
        })
        self.safeAdd(observer: self, forKeyPath: "videoRect", options: [.new , .old], context: nil)
        self.player?.safeAdd(observer: self, forKeyPath: "Muted", options: [.new, .old], context: nil)
        self.player?.safeAdd(observer: self, forKeyPath: "rate", options: [.new, .old], context: nil)
        self.player?.safeAdd(observer: self, forKeyPath: "currentItem", options: [.new , .old], context: nil)
        _cover?.addObserver()
        
    }
    
    fileprivate func removeAllObserver() {
        self.player?.replaceCurrentItem(with: nil)
        self.player?.pause()
        self.safeRemove(observer: self, forKeyPath: "videoRect")
        self.player?.safeRemove(observer: self, forKeyPath: "Muted")
        self.player?.safeRemove(observer: self, forKeyPath: "rate")
        NotificationCenter.default.removeObserver(self)
        self.player?.safeRemove(observer: self, forKeyPath: "currentItem")
        _playView?.safeRemove(observer: self, forKeyPath: "bounds")
        _playView?.safeRemove(observer: self, forKeyPath: "frame")

        _cover?.removeObserver()
        if let t = timeObserver {
            self.player?.removeTimeObserver(t)
            timeObserver = nil
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let k = keyPath {
            switch k {
            case "frame":
                if let o = object as? UIView , o == playView {
                    self.frame = o.bounds
                    self.updateCoverConstraint()
                    if self.coverFitType != .fitToVideoRect {
                        thumbImageView.frame = o.bounds
                        self.indicator?.frame = o.bounds
                    }
                }
                
            case "bounds":
                if let o = object as? UIView , o == playView {
                    self.frame = o.bounds
                    thumbImageView.frame = o.bounds
                    self.indicator?.frame = o.bounds
                    self.updateCoverConstraint()
                }

            case "videoRect":
                let old = (change?[.oldKey] as? CGRect) ?? .zero
                
                if let new = change?[.newKey] as? CGRect ,old != new {
                    self.indicator?.frame = new
                    thumbImageView.frame = new
                    self.updateCoverConstraint()
                }
            case "Muted":
                if let old = change?[.oldKey] as? Bool,
                    let new = change?[.newKey] as? Bool , old != new{
                    _cover?.player?(isMuted: new)
                }
                
            case "rate":
                switch self.currentPlayStatus {
                case .playing, .pause, .ready, .end:
                    if let new = change?[.newKey] as? CGFloat {
                        self.currentPlayStatus = (new == 0.0) ? .pause : .playing
                    }
                default:
                    break
                }
            case "currentItem":
                if let old = change?[.oldKey] as? AVPlayerItem {
                    old.safeRemove(observer: self, forKeyPath: "playbackBufferEmpty")
                    old.safeRemove(observer: self, forKeyPath: "playbackLikelyToKeepUp")
                    old.safeRemove(observer: self, forKeyPath: "status")
                }
                
                if let new = change?[.newKey] as? AVPlayerItem {
                    new.safeAdd(observer: self, forKeyPath: "status", options: [.new], context: nil)
                    
                    new.safeAdd(observer: self, forKeyPath: "playbackLikelyToKeepUp", options: [.new], context: nil)
                    new.safeAdd(observer: self, forKeyPath: "playbackBufferEmpty", options: [.new], context: nil)
                }
            case "playbackBufferEmpty":
                if let c = change?[.newKey] as? Bool, c == true {
                    self.startLoading(isStart: true)
                }
            case "playbackLikelyToKeepUp":
                if let c = change?[.newKey] as? Bool, c == true {
                    self.startLoading(isStart: false)
                }
            case "status":
                let s = self.convertItemStatus()
                
                switch s {
                case .failed(_) , .unknown:
                    self.currentPlayStatus = s
                case .ready:
                    switch self.currentPlayStatus {
                    case .ready:
                        if self.isBackgroundPause {
                            return
                        }
                        self.currentPlayStatus = s
                    case .failed(_):
                        self.currentPlayStatus = s
                    case .unknown:
                        self.currentPlayStatus = s
                    default:
                        break
                    }
                default:
                    break
                }
            default:
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }
    }
    
    fileprivate func convertItemStatus() -> PlayViewPlayStatus {
        if let item = self.player?.currentItem {
            switch item.status {
            case .failed:
                let msg =  item.error?.localizedDescription ??  ""
                return .failed(err: msg)
            case .readyToPlay:
                return .ready
            case .unknown:
                return .unknown
            }
        }
        return .unknown
    }
    
    func touchAction(gesture: UITapGestureRecognizer) {
        if let p = self.playView {
            let point = gesture.location(in: p)
            
            if p.frame.contains(point) {
                self.showCover(isShow: !self.isCoverShow)
            } else {
                
            }
        }
    }

    func showCover(isShow: Bool) {
        self.isCoverShow = isShow
        if isShow {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MMPlayerLayer.showCover(isShow:)), object: nil)
            self.perform(#selector(MMPlayerLayer.showCover(isShow:)), with: nil, afterDelay: self.hideCoverDuration)
        }
        
        if let cover = self.coverView ,
            cover.responds(to: #selector(_cover?.coverView(isShow:))) {
            _cover?.coverView?(isShow: isShow)
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.coverView?.alpha = (isShow) ? 1.0 : 0.0
        })
    }
    
    fileprivate func startLoading(isStart: Bool) {
        if isStart {
            self.indicator?.start()
        } else {
            self.indicator?.stop()
        }
    }
}
