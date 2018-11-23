//
//  MMPlayerLayer.swift
//  Pods
//
//  Created by Millman YANG on 2017/8/22.
//
//

import UIKit
import AVFoundation

public extension MMPlayerLayer {
    public enum PlayerCacheType {
        case none
        case memory(count: Int)
    }
    
    public enum PlayStatus {
        case ready
        case unknown
        case failed(err: String)
        case playing
        case pause
        case end
    }
    
    public enum CoverFitType {
        case fitToPlayerView
        case fitToVideoRect
    }
    
    
    public enum CoverAutoHideType {
        case autoHide(after: TimeInterval)
        case disable
    }
}

public class MMPlayerLayer: AVPlayerLayer {
    fileprivate var frameObservation: NSKeyValueObservation?
    fileprivate var boundsObservation: NSKeyValueObservation?
    fileprivate var videoRectObservation: NSKeyValueObservation?
    fileprivate var mutedObservation: NSKeyValueObservation?
    fileprivate var rateObservation: NSKeyValueObservation?
    fileprivate var isCoverShow = false
    fileprivate var timeObserver: Any?
    fileprivate var isBackgroundPause = false
    fileprivate var cahce = MMPlayerCache()
    fileprivate var playStatusBlock: ((_ status: PlayStatus) ->Void)?
    fileprivate var indicator = MMProgress()
    fileprivate let assetKeysRequiredToPlay = [
        "duration",
        "playable",
        "hasProtectedContent",
        ]
    lazy var tapGesture: UITapGestureRecognizer = {
        let g = UITapGestureRecognizer(target: self, action: #selector(MMPlayerLayer.touchAction(gesture:)))
        return g
    }()
    
    lazy var  bgView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(self.thumbImageView)
        v.addSubview(self.indicator)
        self.indicator.mPlayFit.layoutFitSuper()
        self.thumbImageView.mPlayFit.layoutFitSuper()
        v.frame = .zero
        v.backgroundColor = UIColor.clear
        return v
    }()
    weak fileprivate var _playView: UIView? {
        willSet {
            bgView.removeFromSuperview()
            self.removeFromSuperlayer()
            _playView?.removeGestureRecognizer(tapGesture)
        } didSet {
            guard let new = _playView else {
                return
            }
            new.addSubview(self.bgView)
            self.bgView.mPlayFit.layoutFitSuper()
            self.bgView.layoutIfNeeded()
            self.updateCoverConstraint()
            new.isUserInteractionEnabled = true
            new.addGestureRecognizer(tapGesture)
            new.layer.insertSublayer(self, at: 0)
        }
    }
    
    public weak var mmDelegate: MMPlayerLayerProtocol?
    public var progressType: MMProgress.ProgressType = .default {
        didSet {
            indicator.set(progress: progressType)
        }
    }
    
    public var coverFitType: MMPlayerLayer.CoverFitType = .fitToVideoRect {
        didSet {
            thumbImageView.contentMode = (coverFitType == .fitToVideoRect) ? .scaleAspectFit : .scaleAspectFill
            self.updateCoverConstraint()
        }
    }
    public var autoHideCoverType = MMPlayerLayer.CoverAutoHideType.autoHide(after: 3.0) {
        didSet {
            switch autoHideCoverType {
            case .disable:
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MMPlayerLayer.showCover(isShow:)), object: nil)
            case .autoHide(let after):
                self.perform(#selector(MMPlayerLayer.showCover(isShow:)), with: nil, afterDelay: after)
            }
        }
    }
    public lazy var thumbImageView: UIImageView = {
        let t = UIImageView()
        t.clipsToBounds = true
        return t
    }()
    
    public var playView: UIView? {
        set {
            if self.playView != newValue {
                self._playView = newValue
            }
        } get {
            return _playView
        }
    }
    public var coverView: (UIView & MMPlayerCoverViewProtocol)?
    public var autoPlay = true
    public var currentPlayStatus: PlayStatus = .unknown {
        didSet {
            if let block = self.playStatusBlock {
                block(currentPlayStatus)
            }
            coverView?.currentPlayer(status: currentPlayStatus)
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
                self.startLoading(isStart: false)
            case .unknown:
                self.thumbImageView.isHidden = false
                self.coverView?.isHidden = true
                self.startLoading(isStart: false)
            default:
                self.thumbImageView.isHidden = true
                self.coverView?.isHidden = false
                break
            }
        }
    }
    fileprivate var asset: AVURLAsset?
    public var cacheType: PlayerCacheType = .none
    public var playUrl: URL? {
        willSet {
            self.currentPlayStatus = .unknown
            self.isBackgroundPause = false
            self.player?.replaceCurrentItem(with: nil)
            self.showCover(isShow: false)
            
            guard let url = newValue else {
                return
            }
            self.startLoading(isStart: true)
            if let cacheItem = self.cahce.getItem(key: url) , cacheItem.status == .readyToPlay{
                self.asset = (cacheItem.asset as? AVURLAsset)
                self.player?.replaceCurrentItem(with: cacheItem)
            } else {
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
                            
                            let item = MMPlayerItem(asset: a, delegate: self)
                            switch self?.cacheType {
                            case .some(.memory(let count)):
                                self?.cahce.cacheCount = count
                                self?.cahce.appendCache(key: url, item: item)
                            default:
                                self?.cahce.removeAll()

                            }
                            self?.player?.replaceCurrentItem(with: item)
                        }
                    }
                }
            }
        }
    }

    public func setCoverView(enable: Bool) {
        self.coverView?.isHidden = !enable
        self.tapGesture.isEnabled = enable
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
        CATransaction.setDisableActions(true)
    }
    
    func updateCoverConstraint() {
        let vRect = self.coverFitType == .fitToVideoRect ? videoRect : bgView.bounds
        if vRect.isEmpty {
            self.coverView?.isHidden = true
        } else {
            self.coverView?.isHidden = (self.tapGesture.isEnabled) ? false : true
            self.coverView?.frame = vRect
        }
        self.frame = bgView.bounds
    }
    
    public func delayHideCover() {
        self.showCover(isShow: true)
        switch self.autoHideCoverType {
        case .autoHide(let after):
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MMPlayerLayer.showCover(isShow:)), object: nil)
            self.perform(#selector(MMPlayerLayer.showCover(isShow:)), with: nil, afterDelay: after)
        default:
            break
        }
    }
    public func replace(cover: UIView & MMPlayerCoverViewProtocol) {
        if let c = self.coverView ,c.isMember(of: cover.classForCoder) {
            c.alpha = 1.0
            return
        }
        
        cover.backgroundColor = UIColor.clear
        cover.layoutIfNeeded()
        coverView?.removeFromSuperview()
        coverView?.removeObserver?()
        coverView = cover
        coverView?.playLayer = self
        bgView.insertSubview(cover, belowSubview: indicator)
        cover.addObserver?()
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

    public func getStatusBlock(value: ((_ status: PlayStatus) -> Void)?) {
        self.playStatusBlock = value
    }
    
    public func set(url: URL?, lodDiskIfExist: Bool = true ) {
        if #available(iOS 11.0, *) {
            if let will = url ,
                let real = MMPlayerDownloader.shared.localFileFrom(url: will),
                lodDiskIfExist {
                switch real.type {
                case .hls:
                    var statle = false
                    if let data = try? Data(contentsOf: real.localURL),
                        let convert = try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &statle) {
                        self.willPlayUrl = convert
                    } else {
                        self.willPlayUrl = url
                    }
                case .mp4:
                    self.willPlayUrl = real.localURL
                }
                return
            }
        }
        self.willPlayUrl = url
    }

    public func invalidate() {
        self.willPlayUrl = nil
    }
    
    public func resume() {
        switch self.currentPlayStatus {
        case .playing , .pause:
            if self.playUrl == willPlayUrl { return }
        default:
            break
        }
        self.playUrl = willPlayUrl
    }
    
    @objc func touchAction(gesture: UITapGestureRecognizer) {
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

    @objc public func showCover(isShow: Bool) {
        self.isCoverShow = isShow
        if isShow {
            switch self.autoHideCoverType {
            case .autoHide(let after):
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MMPlayerLayer.showCover(isShow:)), object: nil)
                self.perform(#selector(MMPlayerLayer.showCover(isShow:)), with: nil, afterDelay: after)
            default: break
            }
        }
        
        if let cover = self.coverView ,
            cover.responds(to: #selector(cover.coverView(isShow:))) {
            cover.coverView!(isShow: isShow)
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.coverView?.alpha = (isShow) ? 1.0 : 0.0
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

// Observer
extension MMPlayerLayer {
    
    fileprivate func addPlayerObserver() {
        NotificationCenter.default.removeObserver(self)
        if timeObserver == nil {
            timeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 100), queue: DispatchQueue.main, using: { [weak self] (time) in
                
                if time.isIndefinite {
                    return
                }
                if let cover = self?.coverView, cover.responds(to: #selector(cover.timerObserver(time:))) {
                    cover.timerObserver!(time: time)
                }
            })
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil, using: { [weak self] (nitification) in
            switch self?.currentPlayStatus ?? .unknown {
            case .pause:
                self?.isBackgroundPause = true
            default:
                self?.isBackgroundPause = false
            }
            self?.player?.pause()
        })
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: { [weak self] (nitification) in
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
        
        videoRectObservation = self.observe(\.videoRect, options: [.new, .old]) { [weak self] (player, change) in
            if change.newValue != change.oldValue {
                self?.updateCoverConstraint()
            }
        }

        frameObservation = bgView.observe(\.frame, options: [.new, .old], changeHandler: { [weak self] (view, change) in
            if change.newValue != change.oldValue, change.newValue != .zero {
                self?.updateCoverConstraint()
            }
        })
        
        boundsObservation = bgView.observe(\.bounds, options: [.new, .old], changeHandler: { [weak self] (view, change) in
            if change.newValue != change.oldValue, change.newValue != .zero {
                self?.updateCoverConstraint()
            }
        })
        
        mutedObservation = self.player?.observe(\.isMuted, options: [.new, .old], changeHandler: { [weak self] (play, change) in
            if let new = change.newValue, new != change.oldValue {
                self?.coverView?.player?(isMuted: new)
            }
        })

        rateObservation = self.player?.observe(\.rate, options: [.new, .old], changeHandler: { [weak self] (play, change) in
            guard let new = change.newValue, let status = self?.currentPlayStatus else {
                return
            }
            switch status {
            case .playing, .pause, .ready:
                self?.currentPlayStatus = (new == 0.0) ? .pause : .playing
            case .end:
                let total = self?.player?.currentItem?.duration.seconds ?? 0.0
                let current = self?.player?.currentItem?.currentTime().seconds ?? 0.0
                if current < total {
                    self?.currentPlayStatus = (new == 0.0) ? .pause : .playing
                }
            default:
                break
            }

        })
    }
    
    func removeAllObserver() {
        if let observer = videoRectObservation {
            observer.invalidate()
            self.removeObserver(observer, forKeyPath: "videoRect")
            self.videoRectObservation = nil
        }
        videoRectObservation = nil
        boundsObservation = nil
        frameObservation = nil
        mutedObservation = nil
        rateObservation = nil
        self.player?.replaceCurrentItem(with: nil)
        self.player?.pause()
        NotificationCenter.default.removeObserver(self)
        coverView?.removeObserver?()
        if let t = timeObserver {
            self.player?.removeTimeObserver(t)
            timeObserver = nil
        }
    }

    fileprivate func convertItemStatus() -> MMPlayerLayer.PlayStatus {
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
}


// Download
@available(iOS 11.0, *)
extension MMPlayerLayer {
    public func download(observer status: @escaping ((MMPlayerDownloader.DownloadStatus)->Void)) -> MMPlayerObservation? {
        guard let url = self.playUrl else {
            status(.failed(err: "URL empty"))
            return nil
        }
        if url.isFileURL {
            status(.failed(err: "Input fileURL are Invalid"))
            return nil
        }
        
        MMPlayerDownloader.shared.download(url: url)
        return self.observerDownload(status: status)
    }
    
    public func observerDownload(status: @escaping ((MMPlayerDownloader.DownloadStatus)->Void)) -> MMPlayerObservation? {
        guard let url = self.playUrl else {
            status(.failed(err: "URL empty"))
            return nil
        }
        return MMPlayerDownloader.shared.observe(downloadURL: url, status: status)
    }
}

extension MMPlayerLayer: MMPlayerItemProtocol {
    func status(change: AVPlayerItem.Status) {
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
    }
    
    func isPlaybackKeepUp(isKeepUp: Bool) {
        if isKeepUp == true {
            self.startLoading(isStart: false)
        }
    }
    
    func isPlaybackEmpty(isEmpty: Bool) {
        if isEmpty {
            self.startLoading(isStart: true)
        }
    }
}
