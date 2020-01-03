//
//  MMPlayerItem.swift
//  MMPlayerView
//
//  Created by Millman on 2018/11/16.
//

import UIKit
import AVFoundation
import Combine
protocol MMPlayerItemProtocol: class {
    func status(change: AVPlayerItem.Status)
    func isPlaybackKeepUp(isKeepUp: Bool)
    func isPlaybackEmpty(isEmpty: Bool)
}
class MMPlayerItem: AVPlayerItem {
    var statusObservation: NSKeyValueObservation?
    var keepUpObservation: NSKeyValueObservation?
    var emptyObservation: NSKeyValueObservation?

    weak var delegate: MMPlayerItemProtocol?
    convenience init(asset: AVAsset, delegate: MMPlayerItemProtocol?) {
        self.init(asset: asset, automaticallyLoadedAssetKeys: nil)
        self.delegate = delegate
        self.setup()
    }
    
    func setup() {
        statusObservation = self.observe(\.status, changeHandler: { [weak self] (item, _) in
            self?.delegate?.status(change: item.status)
        })
        keepUpObservation = self.observe(\.isPlaybackLikelyToKeepUp, changeHandler: { [weak self] (item, change) in
            self?.delegate?.isPlaybackKeepUp(isKeepUp: item.isPlaybackLikelyToKeepUp)
        })
        emptyObservation = self.observe(\.isPlaybackBufferEmpty, changeHandler: { [weak self] (item, change) in
            self?.delegate?.isPlaybackEmpty(isEmpty: item.isPlaybackBufferEmpty)
        })
    }
    
    deinit {
        statusObservation?.invalidate()
        keepUpObservation?.invalidate()
        emptyObservation?.invalidate()
        self.statusObservation = nil
        self.keepUpObservation = nil
        self.emptyObservation = nil
    }
}

class MMPlayerItemUI: AVPlayerItem, ObservableObject {
    
    var statusObservation: NSKeyValueObservation?
    var keepUpObservation: NSKeyValueObservation?
    var emptyObservation: NSKeyValueObservation?
    
    
    var statusObserver = PassthroughSubject<AVPlayerItem.Status, Never>()
    var isKeepUpObserver = PassthroughSubject<Bool, Never>()
    var isEmptyObserver = PassthroughSubject<Bool, Never>()

    convenience init(asset: AVAsset) {
        self.init(asset: asset, automaticallyLoadedAssetKeys: nil)
        self.setup()
    
    }
    
    func setup() {
        statusObservation = self.observe(\.status, changeHandler: { [weak self] (item, _) in
            self?.statusObserver.send(item.status)
        })
        keepUpObservation = self.observe(\.isPlaybackLikelyToKeepUp, changeHandler: { [weak self] (item, change) in
            self?.isKeepUpObserver.send(item.isPlaybackLikelyToKeepUp)
        })
        emptyObservation = self.observe(\.isPlaybackBufferEmpty, changeHandler: { [weak self] (item, change) in
            self?.isEmptyObserver.send(item.isPlaybackBufferEmpty)
        })
    }
    
    deinit {
        statusObservation?.invalidate()
        keepUpObservation?.invalidate()
        emptyObservation?.invalidate()
        self.statusObservation = nil
        self.keepUpObservation = nil
        self.emptyObservation = nil
    }
}
