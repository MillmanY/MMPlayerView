//
//  MMPlayerContainer.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/3.
//

import UIKit
import AVFoundation

class MMPlayerContainer: UIView {
    var o: NSKeyValueObservation?
    init(player: AVPlayer) {
        super.init(frame: .zero)
        self.playerLayer.player = player
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        if playerLayer.superlayer != self.layer {
//            self.layer.insertSublayer(playerLayer, at: 0)
//            playerLayer.player?.play()
//        }
        self.playerLayer.frame = self.bounds
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    deinit {
    }
}
