//
//  MMPlayerView.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/24.
//

import SwiftUI
import AVFoundation

let sharedPlayr = AVPlayer()
@available(iOS 13.0.0, *)
struct MMPlayerViewBridge: UIViewRepresentable {
    private let playLayer: AVPlayerLayer

    public init(player: AVPlayerLayer) {
        self.playLayer = player
    }
    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<MMPlayerViewBridge>) {
    
    }
    public func makeUIView(context: Context) -> UIView {
        return MMPlayerContainer(playLayer: playLayer)
    }
}


@available(iOS 13.0.0, *)
public struct MMPlayerViewUI: View {
    private let control: MMPlayerControl
    private let playLayer = AVPlayerLayer()
    //Use Shared AVPlayer Singleton
    public init() {
        self.playLayer.player = sharedPlayr
        self.control = MMPlayerControl(player: sharedPlayr)
    }
    
    public init(player: AVPlayer) {
        self.playLayer.player = player
        self.control = MMPlayerControl(player: player)
    }

    public var body: some View {
        ZStack {
            MMPlayerViewBridge(player: playLayer)
            Color.red.opacity(0.2)
        }
    }
}
