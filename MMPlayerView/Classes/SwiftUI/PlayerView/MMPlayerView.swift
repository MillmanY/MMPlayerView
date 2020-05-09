//
//  MMPlayerView.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/24.
//

import SwiftUI
@available(iOS 13.0.0, *)
public struct MMPlayerViewUI: View {
    @State var rect: CGRect = .zero
    @State var bridge: MMPlayerViewBridge?
    @ObservedObject private var control: MMPlayerControl
    let progress: AnyView?
    let cover: AnyView?
    public var body: some View {
        
        return ZStack {
            bridge
            self.cover?
                .opacity(self.control.isCoverShow ? 1.0 : 0.0)
                .animation(.easeOut(duration: control.coverAnimationInterval))
            self.progress
            self.landscapeView()
        }
        .environmentObject(control)
        .gesture(self.coverTapGesture(), including: .all)
        .modifier(PlayerFramePreference())
        .modifier(FrameModifier<PlayerFramePreference.Key>(rect: $rect))
        .onAppear(perform: {
            self.bridge = MMPlayerViewBridge()
        })
        .onDisappear {
            self.bridge = nil
        }
    }
    
    private func landscapeView() -> some View {
        if self.control.orientation != .protrait && !self.control.landscapeWindow.isKeyWindow && self.bridge != nil {
            self.control.landscapeWindow.start(view: MMPlayerViewWindowUI(view: self.clone(), rect: self.$rect).environmentObject(self.control))
        }
        return EmptyView()
    }
    //TODO ios12 Bug build for crash
    private func coverTapGesture() -> _EndedGesture<TapGesture> {
        return TapGesture().onEnded { (_) in
            self.control.coverViewGestureHandle()
        }
    }
}
@available(iOS 13.0.0, *)
extension MMPlayerViewUI {
    public init<P: View>(control: MMPlayerControl, progress: P) {
        self.init(control: control, pView: AnyView(progress), cView: nil)
    }

    public init<C: View>(control: MMPlayerControl, cover: C) {
        self.init(control: control, pView: AnyView(DefaultIndicator()), cView: AnyView(cover))
    }

    public init<P: View,C: View>(control: MMPlayerControl, progress: P, cover: C) {
        self.init(control: control, pView: AnyView(progress), cView: AnyView(cover))
    }

    public init(control: MMPlayerControl) {
        self.init(control: control, pView: AnyView(DefaultIndicator()), cView: nil)
    }

    init(control: MMPlayerControl,
         pView: AnyView? = AnyView(DefaultIndicator()),
         cView: AnyView? = nil) {
        self.progress = pView
        self.cover = cView
        self.control = control
    }

    private func clone() -> some View {
        return MMPlayerViewUI(control: self.control, progress: self.progress, cover: self.cover)
    }
}
