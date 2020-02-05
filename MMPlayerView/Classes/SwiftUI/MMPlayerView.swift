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
    @State private var orientationCancel: AnyCancellable?
    @EnvironmentObject private var control: MMPlayerControl
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
        .gesture(self.coverTapGesture(), including: .all)
        .modifier(GlobalPlayerFramePreference())
        .onAppear(perform: {
            self.addOrientationObserverOnce()
        })
        .onDisappear {
            self.removeOrientationObserver()
        }
        .onPreferenceChange(GlobalPlayerFramePreference.Key.self) { (values) in
            if let f = values.first, f != .zero {
                DispatchQueue.main.async {
                    self.rect = f
                }
            }
        }
    }
        
    private func addOrientationObserverOnce() {
        self.orientationCancel = self.control.$orientation.sink { (status) in
//            let window = self.control.landscapeWindow
//            switch status {
//            case .protrait:
//                break
////                window.isHidden = true
//            case .landscapeLeft:
//                if window.isKeyWindow {
//                    return
//                }
//                window.isHidden = false
//                window.makeKeyAndVisible()
//            case .landscapeRight:
//                if window.isKeyWindow {
//                    return
//                }
//                let windowV = MMPlayerViewWindowUI(view: self.clone(), rect: self.rect).environmentObject(self.control)
//                window.start(view: windowV)
//            }
            print("\(status) \(self.rect)")

        }
    }
    
    private func removeOrientationObserver() {
        self.orientationCancel?.cancel()
    }
    
    private func coverTapGesture() -> _EndedGesture<TapGesture> {
        return TapGesture().onEnded { (_) in
            self.control.coverViewGestureHandle()
        }
    }
}
@available(iOS 13.0.0, *)
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

    init(pView: AnyView? = AnyView(DefaultIndicator()), cView: AnyView? = nil, isFullScreen: Bool = false) {
        self.progress = pView
        self.cover = cView
    }
    
    private func clone() -> some View {
        return MMPlayerViewUI(progress: self.progress, cover: self.cover)
    }
}
