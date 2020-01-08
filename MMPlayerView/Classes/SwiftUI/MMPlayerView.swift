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
    let progress: AnyView?
    let cover: AnyView?
    
    public var body: some View {
        return ZStack {
            MMPlayerViewBridge(player: playLayer)
            self.cover
            self.progress
        }.environmentObject(control)
    }
}

extension MMPlayerViewUI {
    public init<P: View>(progress: P, player: AVPlayer? = nil) {
        self.init(pView: AnyView(progress), cView: nil, player: player)
    }

    public init<C: View>(cover: C, player: AVPlayer? = nil) {
        self.init(pView: AnyView(DefaultIndicator()), cView: AnyView(cover), player: player)
    }

    public init<P: View,C: View>(progress: P, cover: C, player: AVPlayer? = nil) {
        self.init(pView: AnyView(progress), cView: AnyView(cover), player: player)
    }
    
    public init(player: AVPlayer? = nil) {
        self.init(pView: AnyView(DefaultIndicator()), cView: nil, player: player)
    }

    init(pView: AnyView? = AnyView(DefaultIndicator()), cView: AnyView? = nil, player: AVPlayer? = nil) {

        let p = player ?? sharedPlayr
        self.progress = pView
        self.cover = cView
        self.playLayer.player = p
        self.control = MMPlayerControl(player: p)
        self.playLayer.backgroundColor = UIColor.black.cgColor
        control.set(url: URL.init(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4"))
        control.resume()

    }
}

