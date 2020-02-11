//
//  MMPlayerContainer.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/3.
//

import UIKit
import AVFoundation

class MMPlayerContainer: UIView {
    var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    init(player: AVPlayer?) {
        super.init(frame: .zero)
        self.playerLayer.player = player
        self.backgroundColor = UIColor.black
        self.playerLayer.videoGravity = .resizeAspectFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
