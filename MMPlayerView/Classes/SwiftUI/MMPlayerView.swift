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
    var orientationObserver = OrientationObserver()
    @State var cancel: AnyCancellable?
    @State var rect: CGRect = .zero
    private let control: MMPlayerControl

    let progress: AnyView?
    let cover: AnyView?
    public var body: some View {
        ZStack {
            MMPlayerViewBridge()
            self.cover?
                .opacity(self.control.isCoverShow ? 1.0 : 0.0)
                .animation(.easeOut(duration: control.coverAnimationInterval))
            self.progress
        }
        .onAppear(perform: {
            if !self.orientationObserver.enable {
                return
            }
            self.cancel = self.orientationObserver.$orientation.sink {
                print("\($0)")
            }
        })
            
        .gesture(self.coverTapGesture(), including: .all)
        .modifier(GlobalPlayerFramePreference())
        .onPreferenceChange(GlobalPlayerFramePreference.Key.self) { (values) in
            if let f = values.first, f != .zero {
                DispatchQueue.main.async {
                    self.rect = f
                }
            }
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

    init(control: MMPlayerControl, pView: AnyView? = AnyView(DefaultIndicator()), cView: AnyView? = nil, isFullScreen: Bool = false) {
        self.progress = pView
        self.cover = cView
        self.control = control
    }
    
    private func clone() -> some View {
        return MMPlayerViewUI(control: self.control, progress: self.progress, cover: self.cover)
    }
}
