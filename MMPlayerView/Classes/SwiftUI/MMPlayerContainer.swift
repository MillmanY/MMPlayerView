//
//  MMPlayerContainer.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/3.
//

import UIKit
import AVFoundation
class MMPlayerContainer: UIView {
    unowned var playLayer: AVPlayerLayer
    init(playLayer: AVPlayerLayer) {
        self.playLayer = playLayer
        super.init(frame: .zero)
        self.setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.layer.insertSublayer(playLayer, at: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playLayer.frame = self.bounds
    }
}
