//
//  MMPlayerView.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/24.
//

import SwiftUI
import AVFoundation

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
    @ObservedObject private var control: MMPlayerControl
    private let playLayer = AVPlayerLayer()
    public init() {
        self.init(player: sharedPlayr)
        control.set(url: URL.init(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!)
        control.resume()
    }
    
    public init(player: AVPlayer) {
        self.playLayer.player = player
        self.control = MMPlayerControl(player: player)
        self.playLayer.backgroundColor = UIColor.black.cgColor
    }

    public var body: some View {
        self.progress(view: IndicatorBridge())
    }
    
    public func progress<Progress: View & ProgressUIProtocol>(view: Progress) -> some View {
        return ZStack {
            MMPlayerViewBridge(player: playLayer)
            MMPlayerProgressUI(content: view, isStart: $control.isStart)
        }
    }
}


