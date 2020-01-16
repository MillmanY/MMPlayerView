//
//  MMPlayerContainer.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/3.
//

import UIKit
import AVFoundation


class MMPlayerContainer: UIView {
    let playerLayer: AVPlayerLayer
    init(player: AVPlayer?) {
        self.playerLayer = AVPlayerLayer.init(player: player)
        super.init(frame: .zero)
        self.backgroundColor = UIColor.black
        self.playerLayer.videoGravity = .resizeAspect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if playerLayer.superlayer != self.layer {
            self.layer.insertSublayer(playerLayer, at: 0)
        }
        self.playerLayer.frame = self.superview?.bounds ?? .zero
    }
}
