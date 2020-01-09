//
//  MMPlayerLayer.swift
//  Pods
//
//  Created by Millman YANG on 2017/8/22.
//
//

import UIKit
import AVFoundation

// MARK: - Enum define
public extension MMPlayerLayer {
    enum SubtitleType {
        case srt(info: String)
    }
        
    enum CoverFitType {
        case fitToPlayerView
        case fitToVideoRect
    }
        
    enum OrientationStatus: Int {
        case landscapeLeft
        case landscapeRight
        case protrait
    }
}

public class MMPlayerLayer: AVPlayerLayer {
    /**
     Subtitle Setting
     
     ```
     subtitleSetting.defaultFont = UIFont.systemFont(ofSize: 17)
     subtitleSetting.defaultTextColor = .white
     subtitleSetting.defaultLabelEdge = (20,10,10)
     subtitleSetting.subtitleType = .srt(info: "XXX")
     ```
     */
    public private(set) lazy var subtitleSetting: MMSubtitleSetting = {
        return MMSubtitleSetting(delegate: self)
    }()
    /**
     Set progress type on player center
     
     ```
     mmplayerLayer.progressType = .custom(view: UIView & MMProgressProtocol)
     ```
     */
    public var progressType: MMProgress.ProgressType = .default {
        didSet {
            indicator.set(progress: progressType)
        }
    }
    /**
     Set progress type on player center
     
     ```
     // Cover view fit to videoRect
     mmplayerLayer.coverFitType = .fitToVideoRect
     // Cover view fit to playerLayer frame
     mmplayerLayer.coverFitType = .fitToPlayerView
     ```
     */
    public var coverFitType: MMPlayerLayer.CoverFitType = .fitToVideoRect {
        didSet {
            thumbImageView.contentMode = (coverFitType == .fitToVideoRect) ? .scaleAspectFit : .scaleAspectFill
            self.updateCoverConstraint()
        }
    }
    /**
     Set cover view auto hide after n interval
     
     ```
     // Cover view auto hide with n interval
     mmplayerLayer.autoHideCoverType = .MMPlayerLayer.CoverAutoHideType.autoHide(after: 3.0)
     // Cover view auto hide disable
     mmplayerLayer.autoHideCoverType = .disable
     ```
     */
    public var autoHideCoverType = CoverAutoHideType.autoHide(after: 3.0) {
        didSet {
            switch autoHideCoverType {
            case .disable:
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(MMPlayerLayer.showCover(isShow:)), object: nil)
            case .autoHide(let after):
                self.perform(#selector(MMPlayerLayer.showCover(isShow:)), with: nil, afterDelay: after)
            }
        }
    }
    /**
     Set to show image before video ready
     
     ```
     // Set thumbImageView
     mmplayerLayer.thumbImageView.image = 'Background Image'
     ```
     */
    public lazy var thumbImageView: UIImageView = {
        let t = UIImageView()
        t.clipsToBounds = true
        return t
    }()
    /**
     MMPlayerLayer will show in playView
     
     ```
     // Set thumbImageView
     mmplayerLayer.playView = cell.imageView
     ```
     */
    public var playView: UIView? {
        set {
            if self.playView != newValue {
                self._playView = newValue
            }
        } get {
            return _playView
        }
    }
    
    /**
     Loop video when end
     
     ```
     mmplayerLayer.repeatWhenEnd = true
     ```
     */
    public var repeatWhenEnd: Bool = false
    /**
     Current cover view on mmplayerLayer
     
     ```
     mmplayerLayer.coverView
     ```
     */
    public private(set) var coverView: (UIView & MMPlayerCoverViewProtocol)?
    /**
     Auto play when video ready
     */
    public var autoPlay = true
    /**
     Current player status
     
     ```
     case ready
     case unknown
     case failed(err: String)
     case playing
     case pause
     case end
     ```
     */
    public var currentPlayStatus: PlayStatus = .unknown {
        didSet {
            if currentPlayStatus == oldValue {
                return
            }
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
    /**
     Set AVPlayerItem cache in memory or not
     
     ```
     case none
     case memory(count: Int)
     ```
     */
    public var cacheType: PlayerCacheType = .none
    /**
     Current play url
     */
    public var playUrl: URL? {
        get {
            return (self.player?.currentItem?.asset as? AVURLAsset)?.url
        }
    }
    public weak var mmDelegate: MMPlayerLayerProtocol?
    /**
     If true, player will fullscreen when roatate to landscape
     ```
     mmplayerLayer.fullScreenWhenLandscape = true
     ```
     */
    public var fullScreenWhenLandscape = true
    /**
     Player current orientation
     
     ```
     mmplayerLayer.orientation = .protrait
     mmplayerLayer.orientation = .landscapeLeft
     mmplayerLayer.orientation = .landscapeRight
     ```
     */
    public private(set) var orientation: OrientationStatus = .protrait {
        didSet {
            self.landscapeWindow.update()
            if orientation == oldValue { return }
            self.layerOrientationBlock?(orientation)
        }
    }
    
    public var isShrink: Bool {
        return shrinkControl.isShrink
    }
    
    // MARK: - Private Parameter
    lazy var subtitleView = MMSubtitleView()
    lazy var shrinkControl = {
       return MMPlayerShrinkControl(mmPlayerLayer: self)
    }()

    private lazy var  bgView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(self.thumbImageView)
        v.addSubview(self.indicator)
//        self.indicator
//            .mmLayout
//            .setCenterX(anchor: v.centerXAnchor, type: .equal(constant: 0))
//            .setCentoMerY(anchor: v.centerYAnchor, type: .equal(constant: 0))

        self.indicator.mmLayout.layoutFitSuper()
        self.thumbImageView.mmLayout.layoutFitSuper()
        v.frame = .zero
        v.backgroundColor = UIColor.clear
        return v
    }()
   
    private lazy var tapGesture: UITapGestureRecognizer = {
        let g = UITapGestureRecognizer(target: self, action: #selector(MMPlayerLayer.touchAction(gesture:)))
        return g
    }()
    
    private lazy var landscapeWindow: MMLandscapeWindow = {
        let window = MMLandscapeWindow(playerLayer: self)
        return window
    }()
    
    weak private var _playView: UIView? {
        willSet {
            bgView.removeFromSuperview()
            self.removeFromSuperlayer()
            _playView?.removeGestureRecognizer(tapGesture)
        } didSet {
            guard let new = _playView else {
                return
            }
            new.layer.insertSublayer(self, at: 0)
            new.addSubview(self.bgView)
            self.bgView.mmLayout.layoutFitSuper()
            new.layoutIfNeeded()
            self.updateCoverConstraint()
            new.isUserInteractionEnabled = true
            new.addGestureRecognizer(tapGesture)

        }
    }
    private var asset: AVURLAsset?
    private var isInitLayer = false
    private var isCoverShow = false
    private var timeObserver: Any?
    private var isBackgroundPause = false
    private var cahce = MMPlayerCache()
    private var playStatusBlock: ((_ status: PlayStatus) ->Void)?
    private var layerOrientationBlock: ((_ status: OrientationStatus) ->Void)?
    private var indicator = MMProgress()
    // MARK: - Init
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
    
    deinit {
        if !isInitLayer {
            self.removeAllObserver()
        }
    }
}

// MARK: - Public function
extension MMPlayerLayer {
    
    public func shrinkView(onVC: UIViewController, isHiddenVC: Bool, maxWidth: CGFloat = 150.0, completedToView: (()->UIView?)?) {
        shrinkControl.shrinkView(onVC: onVC, isHiddenVC: isHiddenVC, maxWidth: maxWidth, completedToView: completedToView)
    }
    /**
     Set player current Orientation
     
     ```
     mmplayerLayer.setOrientation(.protrait)
     ```
     */
    public func setOrientation(_ status: MMPlayerLayer.OrientationStatus) {
        self.orientation = status
    }
    
    /**
     If cover enable show on video, else hidden
     */
    public func setCoverView(enable: Bool) {
        self.coverView?.isHidden = !enable
        self.tapGesture.isEnabled = enable
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
    
    /**
     Set player cover view
     ** Cover view need implement 'MMPlayerCoverViewProtocol' **
     
     ```
     mmplayerLayer.replace(cover: XXX)
     ```
     */
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
    /**
     Get player play status
     */
    public func getStatusBlock(value: ((_ status: PlayStatus) -> Void)?) {
        self.playStatusBlock = value
    }
    /**
     Get player orientation status
     */
    public func getOrientationChange(status: ((_ status: OrientationStatus) ->Void)?) {
        self.layerOrientationBlock = status
    }
    
    public func set(asset: AVURLAsset?, lodDiskIfExist: Bool = true) {
        if asset?.url == self.asset?.url {
            return
        }
        if let will = asset ,
            self.cahce.getItem(key: will.url) == nil,
            let real = MMPlayerDownloader.shared.localFileFrom(url: will.url),
            lodDiskIfExist {
            switch real.type {
            case .hls:
                var statle = false
                if let data = try? Data(contentsOf: real.localURL),
                    let convert = try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &statle) {
                    self.asset = AVURLAsset(url: convert)
                } else {
                    self.asset = asset
                }
            case .mp4:
                self.asset = AVURLAsset(url: real.localURL)
            }
            return
        }
        self.asset = asset
    }
    
    /**
     Set player playUrl
     */
    public func set(url: URL?, lodDiskIfExist: Bool = true) {
        guard let u = url else {
            self.set(asset: nil, lodDiskIfExist: lodDiskIfExist)
            return
        }
        self.set(asset: AVURLAsset(url: u), lodDiskIfExist: lodDiskIfExist)
    }
    /**
     Stop player and clear url
     */
    public func invalidate() {
        self.initStatus()
        self.asset = nil
    }
    /**
     Start player to play video
     */
    public func resume() {
        switch self.currentPlayStatus {
        case .playing , .pause:
            if (self.player?.currentItem?.asset as? AVURLAsset)?.url == self.asset?.url {
                return
            }
        default:
            break
        }
        self.initStatus()
        guard let current = self.asset else {
            return
        }
        self.startLoading(isStart: true)
        if let cacheItem = self.cahce.getItem(key: current.url) , cacheItem.status == .readyToPlay {
            self.player?.replaceCurrentItem(with: cacheItem)
        } else {
            current.loadValuesAsynchronously(forKeys: assetKeysRequiredToPlay) { [weak self] in
                DispatchQueue.main.async {
                    let keys = assetKeysRequiredToPlay
                    if let a = self?.asset {
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
                        self?.cahce.appendCache(key: current.url, item: item)
                    default:
                        self?.cahce.removeAll()
                    }
                    self?.player?.replaceCurrentItem(with: item)
                    }
                }
            }
        }
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
}

// MARK: - Private function
extension MMPlayerLayer {
    private func setup() {
        self.player = AVPlayer()
        self.backgroundColor = UIColor.black.cgColor
        self.progressType = .default
        self.addPlayerObserver()
        bgView.addSubview(subtitleView)
        subtitleView.mmLayout.layoutFitSuper()
        let edge = subtitleSetting.defaultLabelEdge
        self.subtitleSetting.defaultLabelEdge = edge
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { [weak self] (_) in
            guard let self = self, self.fullScreenWhenLandscape else {return}
            
            switch UIDevice.current.orientation {
            case .landscapeLeft:
                self.orientation = .landscapeLeft
            case .landscapeRight:
                self.orientation = .landscapeRight
            case .portrait:
                self.orientation = .protrait
            default: break
            }
        }
    }
    
    private func updateCoverConstraint() {
        let vRect = self.coverFitType == .fitToVideoRect ? videoRect : bgView.bounds
        if !vRect.isEmpty {
            self.coverView?.isHidden = (self.tapGesture.isEnabled) ? false : true
            self.coverView?.frame = vRect
        }
        if bgView.bounds == self.frame { return }

        self.frame = bgView.bounds
    }
    
    private func startLoading(isStart: Bool) {
        if isStart {
            self.indicator.start()
        } else {
            self.indicator.stop()
        }
    }
}

// MARK: - Observer
extension MMPlayerLayer {
    private func addPlayerObserver() {
        NotificationCenter.default.removeObserver(self)
        if timeObserver == nil {
            timeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 100), queue: DispatchQueue.main, using: { [weak self] (time) in
                
                if time.isIndefinite {
                    return
                }
                if let sub = self?.subtitleSetting.subtitleObj {
                    switch sub {
                    case let srt as SubtitleConverter<SRT>:
                        let sec = time.seconds
                        srt.search(duration: sec, completed: { [weak self] (info) in
                            guard let self = self else {return}
                            self.subtitleView.update(infos: info, setting: self.subtitleSetting)
                        }, queue: DispatchQueue.main)
                    default:
                        break
                    }
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
          
            if self?.repeatWhenEnd == true {
                self?.player?.seek(to: CMTime.zero)
                self?.player?.play()
            } else if let s = self?.currentPlayStatus {
                switch s {
                case .playing, .pause:
                    if let u = self?.asset?.url {
                        self?.cahce.removeCache(key: u)
                    }
                    self?.currentPlayStatus = .end
                default: break
                }
            }
        })
        self.addObserver(self, forKeyPath: "videoRect", options: [.new, .old], context: nil)
        bgView.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)
        bgView.addObserver(self, forKeyPath: "bounds", options: [.new, .old], context: nil)
        self.player?.addObserver(self, forKeyPath: "muted", options: [.new, .old], context: nil)
        self.player?.addObserver(self, forKeyPath: "rate", options: [.new, .old], context: nil)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        switch keyPath {
        case "videoRect", "frame", "bounds":
            let new = change?[.newKey] as? CGRect ?? .zero
            let old = change?[.oldKey] as? CGRect ?? .zero
         if new != old {
                self.updateCoverConstraint()
            }
        case "muted":
            let new = change?[.newKey] as? Bool ?? false
            let old = change?[.oldKey] as? Bool ?? false
            if new != old {
                self.coverView?.player?(isMuted: new)
            }
        case "rate":
            let new = change?[.newKey] as? Float ?? 1.0
            let status = self.currentPlayStatus
            switch status {
            case .playing, .pause, .ready:
                self.currentPlayStatus = (new == 0.0) ? .pause : .playing
            case .end:
                let total = self.player?.currentItem?.duration.seconds ?? 0.0
                let current = self.player?.currentItem?.currentTime().seconds ?? 0.0
                if current < total {
                    self.currentPlayStatus = (new == 0.0) ? .pause : .playing
                }
            default: break
            }

        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func removeAllObserver() {
        self.removeObserver(self, forKeyPath: "videoRect")
        bgView.removeObserver(self, forKeyPath: "frame")
        bgView.removeObserver(self, forKeyPath: "bounds")
        self.player?.removeObserver(self, forKeyPath: "muted")
        self.player?.removeObserver(self, forKeyPath: "rate")
        self.player?.replaceCurrentItem(with: nil)
        self.player?.pause()
        NotificationCenter.default.removeObserver(self)
        coverView?.removeObserver?()
        if let t = timeObserver {
            self.player?.removeTimeObserver(t)
            timeObserver = nil
        }
    }

    private func convertItemStatus() -> PlayStatus {
        return self.player?.currentItem?.convertStatus() ?? .unknown
    }
    
    private func initStatus() {
        self.currentPlayStatus = .unknown
        self.isBackgroundPause = false
        self.player?.replaceCurrentItem(with: nil)
        self.showCover(isShow: false)
    }
}

// MARK: - Download
extension MMPlayerLayer {
    
    public func download(observer status: @escaping ((MMPlayerDownloader.DownloadStatus)->Void)) -> MMPlayerObservation? {
        guard let asset = self.asset else {
            
            status(.failed(err: "URL empty"))
            return nil
        }
        if asset.url.isFileURL {
            status(.failed(err: "Input fileURL are Invalid"))
            return nil
        }
        
        MMPlayerDownloader.shared.download(asset: asset)
        return self.observerDownload(status: status)
    }
    
    public func observerDownload(status: @escaping ((MMPlayerDownloader.DownloadStatus)->Void)) -> MMPlayerObservation? {
        guard let url = self.asset?.url else {
            status(.failed(err: "URL empty"))
            return nil
        }
        return MMPlayerDownloader.shared.observe(downloadURL: url, status: status)
    }
}

// MARK: - MMPlayerItem delegate
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

extension MMPlayerLayer: MMSubtitleSettingProtocol {
    public func setting(_ mmsubtitleSetting: MMSubtitleSetting, fontChange: UIFont) {
    }
    public func setting(_ mmsubtitleSetting: MMSubtitleSetting, textColorChange: UIColor) {

    }
    public func setting(_ mmsubtitleSetting: MMSubtitleSetting, labelEdgeChange: (bottom: CGFloat, left: CGFloat, right: CGFloat)) {
        
    }
    
    public func setting(_ mmsubtitleSetting: MMSubtitleSetting, typeChange: MMSubtitleSetting.SubtitleType?) {
        self.subtitleView.isHidden = typeChange == nil
    }
}
