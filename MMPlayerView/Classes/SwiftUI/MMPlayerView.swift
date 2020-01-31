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
    @EnvironmentObject var control: MMPlayerControl

    public func updateUIView(_ uiView: MMPlayerContainer, context: UIViewRepresentableContext<MMPlayerViewBridge>) {
    }
    public func makeUIView(context: Context) -> MMPlayerContainer {
        return MMPlayerContainer(player: control.player)
    }
    
    static func dismantleUIView(_ uiView: MMPlayerContainer, coordinator: MMPlayerViewBridge.Coordinator) {
        uiView.playerLayer.player = nil
    }

}


@available(iOS 13.0.0, *)
public struct MMPlayerViewUI: View {
    @EnvironmentObject private var control: MMPlayerControl
    let progress: AnyView?
    let cover: AnyView?
    @State var r: CGRect = .zero
    public var body: some View {
        return ZStack {
            MMPlayerViewBridge()
            self.cover?
                .opacity(self.control.isCoverShow ? 1.0 : 0.0)
                .animation(.easeOut(duration: control.coverAnimationInterval))
            self.progress
        }            
        .gesture(self.coverTapGesture(), including: .all)
        .modifier(GlobalPlayerFramePreference())
    }

    private func coverTapGesture() -> _EndedGesture<TapGesture> {
        return TapGesture().onEnded { (_) in
            self.control.coverViewGestureHandle()
        }
    }
}

extension MMPlayerViewUI {
    public init<P: View>(progress: P) {
        self.init(pView: AnyView(progress), cView: nil)
    }

    public init<C: View>(cover: C) {
        self.init(pView: AnyView(DefaultIndicator()), cView: AnyView(cover))
    }

    public init<P: View,C: View>(progress: P, cover: C) {
        self.init(pView: AnyView(progress), cView: AnyView(cover))
    }
    
    public init() {
        self.init(pView: AnyView(DefaultIndicator()), cView: nil)
    }

    init(pView: AnyView? = AnyView(DefaultIndicator()), cView: AnyView? = nil) {
        self.progress = pView
        self.cover = cView
    }
}

