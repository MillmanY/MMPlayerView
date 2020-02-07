//
//  MMPlayerView.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/24.
//

import SwiftUI
import AVFoundation
import Combine
@available(iOS 13.0.0, *)
public struct MMPlayerViewUI: View {
    @State var rect: CGRect = .zero
    @State var cancelable: AnyCancellable?
    @ObservedObject private var control: MMPlayerControl
    let progress: AnyView?
    let cover: AnyView?
    public var body: some View {
        return ZStack {
            MMPlayerViewBridge()
            self.cover?
                .opacity(self.control.isCoverShow ? 1.0 : 0.0)
                .animation(.easeOut(duration: control.coverAnimationInterval))
            self.progress
        }
        .gesture(self.coverTapGesture(), including: .all)
        .modifier(GlobalFramePreference())
        .modifier(FrameModifier<GlobalFramePreference.Key>(rect: $rect))
        .onAppear(perform: {
            if self.control.landscapeWindow.isKeyWindow {
                return
            }
            self.cancelable = self.control.$orientation.sink(receiveValue: {
                switch $0 {
                case .protrait:
                    break
                default:
                    self.control.landscapeWindow.start(view: MMPlayerViewWindowUI(view: self.clone(), rect: self.rect).environmentObject(self.control))
                }
            })
        })
        .onDisappear {
            self.cancelable?.cancel()
        }
    }
    
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
