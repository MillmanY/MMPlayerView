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
    lazy var tapGesture: UITapGestureRecognizer = {
        let g = UITapGestureRecognizer.init(target: self, action: #selector(MMPlayerLayer.touchAction(gesture:)))
        return g
    }()

    fileprivate var isCoverShow = false
    fileprivate var timeObserver: Any?
    fileprivate var isBackgroundPause = false
    fileprivate var _cover: MMPlayerCoverViewProtocol?
    fileprivate var cahce = MMPlayerCache()
    fileprivate var playStatusBlock: ((_ status: MMPlayerPlayStatus) ->Void)?
    fileprivate let assetKeysRequiredToPlay = [
        "duration",
        "playable",
        "hasProtectedContent",
    ]
    
    fileprivate lazy var indicator: MMProgress = {
        let i = MMProgress()
        return i
    }()

    weak fileprivate var _playView: UIView? {
        willSet {
            coverView?.removeFromSuperview()
            indicator.removeFromSuperview()
            self.removeFromSuperlayer()
            _playView?.removeGestureRecognizer(tapGesture)
            _playView?.havePlayer = false
        } didSet {
            _playView?.isUserInteractionEnabled = true
            _playView?.addGestureRecognizer(tapGesture)
            _playView?.layer.insertSublayer(self, at: 0)
            _playView?.havePlayer = true
            self.uploadSubViewIdx()
        }
    }
    
    fileprivate func uploadSubViewIdx() {
        _playView?.addSubview(thumbImageView)
        if let c = coverView {
            _playView?.addSubview(c)
        }
        _playView?.addSubview(indicator)
        indicator.setup()
    }
    public weak var mmDelegate: MMPlayerLayerProtocol?
    public var progressType: ProgressType = .default {
        didSet {
            indicator.set(progress: progressType)
        }
    }
    
    public var coverFitType: CoverViewFitType = .fitToVideoRect {
        didSet {
            
            thumbImageView.contentMode = (coverFitType == .fitToVideoRect) ? .scaleAspectFit : .scaleAspectFill
            self.updateCoverConstraint()
        }
    }
    public var changeViewClearPlayer = true
    var clearURLWhenChangeView = true
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
                
                if clearURLWhenChangeView && changeViewClearPlayer {
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
    public var autoPlay = true
    public var currentPlayStatus: MMPlayerPlayStatus = .unknown {
        didSet {
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
            case .failed(err: _):
                self.thumbImageView.isHidden = false
                self.coverView?.isHidden = false
            case .unknown:
                self.thumbImageView.isHidden = false
                self.coverView?.isHidden = true
            default:
                self.thumbImageView.isHidden = true
                self.coverView?.isHidden = false
                break
            }
        }
    }
    public var cacheInMemory = false
    public var playUrl: URL? {
        willSet {
            self.currentPlayStatus = .unknown
            self.isBackgroundPause = false
            self.player?.replaceCurrentItem(with: nil)
            self.showCover(isShow: false)
            
            guard let url = newValue else {
                return
            }
            if let cacheItem = self.cahce.getItem(key: url) , cacheItem.status == .readyToPlay{
                self.player?.replaceCurrentItem(with: cacheItem)
            } else {
                self.startLoading(isStart: true)
                let asset = AVURLAsset(url: url)
                asset.loadValuesAsynchronously(forKeys: assetKeysRequiredToPlay) { [weak self] in
                    DispatchQueue.main.async {
                        if let keys = self?.assetKeysRequiredToPlay {
                            for key in keys {
                                var error: NSError?
                                let _ =  asset.statusOfValue(forKey: key, error: &error)
                                if let e = error {
                                    self?.currentPlayStatus = .failed(err: e.localizedDescription)
                                    return
                                }
                            }
                            
                            let item = AVPlayerItem(asset: asset)
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
        DispatchQueue.main.async { [unowned self] in
            self.coverView?.isHidden = !enable
            self.tapGesture.isEnabled = enable
        }
    }
    
    fileprivate var isInitLayer = false
    public override init(layer: Any) {
        isInitLayer = true
        super.init(layer: layer)
        (layer as? MMPlayerLayer)?.isInitLayer = false
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
        self.backgroundColor = UIColor.black.cgColor
        self.progressType = .default
        self.addPlayerObserver()
    }
    
    func updateCoverConstraint() {
        let vRect = self.coverFitType == .fitToVideoRect ? videoRect : (playView?.bounds ?? .zero)
        if vRect.isEmpty {
            self.coverView?.isHidden = true
        } else {
            self.coverView?.isHidden = false
            self.coverView?.frame = vRect
        }
        
        self.indicator.frame = (playView?.bounds ?? .zero)
        thumbImageView.frame = (playView?.bounds ?? .zero)
    }
    
    public func delayHideCover() {
        self.showCover(isShow: true)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MMPlayerLayer.showCover(isShow:)), object: nil)
        self.perform(#selector(MMPlayerLayer.showCover(isShow:)), with: nil, afterDelay: hideCoverDuration)
    }
    
    public func replace<T: UIView>(cover:T) where T: MMPlayerCoverViewProtocol{
        if let c = self.coverView ,c.isMember(of: cover.classForCoder) {
            c.alpha = 1.0
            return
        }
        cover.backgroundColor = UIColor.clear
        cover.layoutIfNeeded()
        
        (_cover as? UIView)?.removeFromSuperview()
        _cover?.removeObserver()
        _cover = cover
        _cover?.playLayer = self
        self.uploadSubViewIdx()
        cover.addObserver()
        self.updateCoverConstraint()
        if let m = self.player?.isMuted {
            cover.player?(isMuted: m)
        }
        cover.currentPlayer(status: self.currentPlayStatus)
    }
    
    fileprivate var willPlayUrl: URL? {
        didSet {
            if oldValue != willPlayUrl {
                self.playUrl = nil
            }
        }
    }
    public func set(url: URL?, state: ((_ status: MMPlayerPlayStatus) -> Void)?) {
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
    }
    
    func removeAllObserver() {
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
            case "videoRect":
                let old = (change?[.oldKey] as? CGRect) ?? .zero
                
                if let new = change?[.newKey] as? CGRect ,old != new {
                    self.updateCoverConstraint()
                }
            case "Muted":
                if let old = change?[.oldKey] as? Bool,
                    let new = change?[.newKey] as? Bool , old != new{
                    _cover?.player?(isMuted: new)
                }
                
            case "rate":
                switch self.currentPlayStatus {
                case .playing, .pause, .ready:
                    if let new = change?[.newKey] as? CGFloat {
                        self.currentPlayStatus = (new == 0.0) ? .pause : .playing
                    }
                case .end:
                    let total = self.player?.currentItem?.duration.seconds ?? 0.0
                    let current = self.player?.currentItem?.currentTime().seconds ?? 0.0
                    if let new = change?[.newKey] as? CGFloat , current < total {
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
                    case .failed(_) ,.unknown:
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
    
    fileprivate func convertItemStatus() -> MMPlayerPlayStatus {
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
        switch self.currentPlayStatus {
        case .unknown:
            return
        default: break
        }
        
        if let p = self.playView {
            let point = gesture.location(in: p)
            if self.videoRect.isEmpty || self.videoRect.contains(point) {
                self.showCover(isShow: !self.isCoverShow)
            }
            mmDelegate?.touchInVideoRect(contain: self.videoRect.contains(point))
        }
    }

    public func showCover(isShow: Bool) {
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
            self.indicator.start()
        } else {
            self.indicator.stop()
        }
    }
    deinit {
        if !isInitLayer {
            self.removeAllObserver()
        }
    }
}
