//
//  MMPlayerControl.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/3.
//

import Foundation
import AVFoundation
import Combine

public class MMPlayerControl: ObservableObject {
    static let shared = MMPlayerControl(player: sharedPlayr)
    private var asset: AVURLAsset?
    private var timeObserver: Any?
    private var muteObserver: NSKeyValueObservation?
    private var rateObserver: NSKeyValueObservation?
    private var cahce = MMPlayerCache()
    private var itemCancel = [AnyCancellable]()

    @Published
    public var currentTime: CMTime = .zero
    @Published
    public var isMuted = false
    @Published
    public var isBackgroundPause = true
    @Published
    public var currentPlayStatus: PlayStatus = .unknown
    @Published
    public var repeatWhenEnd: Bool = false
    @Published
    public var isLoading: Bool = false
    public var cacheType: PlayerCacheType = .memory(count: 10)

    unowned var player: AVPlayer
    init(player: AVPlayer) {
        self.player = player
        self.setup()
    }
    
    private func setup() {
        self.addPlayerObserver()
    }
    private func initStatus() {
        self.isLoading = false
        self.currentPlayStatus = .unknown
        self.isBackgroundPause = false
        self.replace(item: nil)
//        self.showCover(isShow: false)
    }
    
    deinit {
        self.initStatus()
    }
}

extension MMPlayerControl {
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
    
    public func set(url: URL?, lodDiskIfExist: Bool = true) {
        guard let u = url else {
            self.set(asset: nil, lodDiskIfExist: lodDiskIfExist)
            return
        }
        self.set(asset: AVURLAsset(url: u), lodDiskIfExist: lodDiskIfExist)
    }
    
    public func resume() {
        switch self.currentPlayStatus {
        case .playing , .pause:
            if (self.player.currentItem?.asset as? AVURLAsset)?.url == self.asset?.url {
                return
            }
        default:
            break
        }
        self.initStatus()
        guard let current = self.asset else {
            return
        }
        isLoading = true
        if let cacheItem = self.cahce.getItem(key: current.url) , cacheItem.status == .readyToPlay {
            self.replace(item: cacheItem)
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
                        let item = MMPlayerItemUI(asset: a)
                        self?.replace(item: item)
                        switch self?.cacheType {
                        case .some(.memory(let count)):
                            self?.cahce.cacheCount = count
                            self?.cahce.appendCache(key: current.url, item: item)
                        default:
                            self?.cahce.removeAll()
                        }
                    }
                }
            }
        }
    }
    private func replace(item: AVPlayerItem?) {
        itemCancel.forEach { $0.cancel() }
        itemCancel.removeAll()
        guard let item = item as? MMPlayerItemUI else {
            self.player.replaceCurrentItem(with: nil)
            return
        }
        let o1 = item.statusObserver.sink { [weak self] (status) in
            guard let self = self else {return}
            let s = self.player.currentItem?.convertStatus() ?? .unknown
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
                self.player.play()
            default:
                break
            }
        }
        let o2 = item.isKeepUpObserver.sink { [weak self] (value) in
            if value {
                self?.isLoading = false
            }
        }
        let o3 = item.isEmptyObserver.sink { [weak self] (value) in
            if value {
                self?.isLoading = true
            }
        }
        
        let o4 = self.$currentPlayStatus.sink { [weak self] (value) in
            switch value {
            case .unknown, .failed(_):
                self?.isLoading = false
            default:
                break
            }
        }
        
        self.itemCancel = [o1,o2,o3,o4]
        self.player.replaceCurrentItem(with: item)
    }

}

extension MMPlayerControl {
    private func addPlayerObserver() {
        NotificationCenter.default.removeObserver(self)
    
        timeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 100), queue: DispatchQueue.main, using: { [weak self] (time) in
                
            if time.isIndefinite {
                return
            }
//                if let sub = self?.subtitleSetting.subtitleObj {
//                    switch sub {
//                    case let srt as SubtitleConverter<SRT>:
//                        let sec = time.seconds
//                        srt.search(duration: sec, completed: { [weak self] (info) in
//                            guard let self = self else {return}
//                            self.subtitleView.update(infos: info, setting: self.subtitleSetting)
//                        }, queue: DispatchQueue.main)
//                    default:
//                        break
//                    }
//                }
//
            self?.currentTime = time
        })
        
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil, using: { [weak self] (nitification) in
            switch self?.currentPlayStatus ?? .unknown {
            case .pause:
                self?.isBackgroundPause = true
            default:
                self?.isBackgroundPause = false
            }
            self?.player.pause()
        })
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: { [weak self] (nitification) in
            if self?.isBackgroundPause == false {
                self?.player.play()
            }
            self?.isBackgroundPause = false
        })
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil, using: { [weak self] (_) in

            if self?.repeatWhenEnd == true {
                self?.player.seek(to: CMTime.zero)
                self?.player.play()
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
        muteObserver = self.player.observe(\.isMuted, options: [.new, .old], changeHandler: { [weak self] (_, value) in
            let new = value.newValue ?? false
            let old = value.newValue ?? false
            if new != old {
                self?.isMuted = new
            }
        })
        
        rateObserver = self.player.observe(\.rate, options: [.new], changeHandler: { [weak self] (_, value) in
            guard let self = self else {return}
            let new = value.newValue ?? 1.0
            let status = self.currentPlayStatus
            switch status {
            case .playing, .pause, .ready:
                self.currentPlayStatus = (new == 0.0) ? .pause : .playing
            case .end:
                let total = self.player.currentItem?.duration.seconds ?? 0.0
                let current = self.player.currentItem?.currentTime().seconds ?? 0.0
                if current < total {
                    self.currentPlayStatus = (new == 0.0) ? .pause : .playing
                }
            default: break
            }
        })
    }
}

