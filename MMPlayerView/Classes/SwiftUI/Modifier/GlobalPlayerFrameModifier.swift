//
//  ObserverPlayUIFrame.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/22.
//

import Foundation
import SwiftUI
import Combine

public struct DownloaderModifier: ViewModifier {
    var download = MMPlayerDownloader.shared
    public func body(content: Content) -> some View {
        content
    }
}

public struct GlobalPlayerFrameModifier: ViewModifier {
    @Binding var r: CGRect
    public init (rect: Binding<CGRect> = .constant(.zero)) {
        self._r = rect
    }
    public func body(content: Content) -> some View {
        content
            .onPreferenceChange(GlobalPlayerFramePreference.Key.self) { (values) in
            if let f = values.first, f != .zero {
                self.r = f
            }
        }
    }
}

public struct GlobalPlayerFramePreference: ViewModifier {
    public func body(content: Content) -> some View {
        content.background(GeometryReader{ (proxy) in
            return Color.clear
            .preference(key: Key.self,
                        value: [proxy.frame(in: .global)])
        })
    }
}

public extension GlobalPlayerFramePreference {
    struct Key: PreferenceKey, Equatable {
        public static var defaultValue: [CGRect] = []
        public static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
            let n = nextValue()
            if n.count > 0 {
                value.append(contentsOf: n)
            }
        }
    }
}
