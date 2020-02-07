//
//  ObserverPlayUIFrame.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/22.
//

import Foundation
import SwiftUI
@available(iOS 13.0.0, *)
struct GlobalFramePreference: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        content.background(GeometryReader{ (proxy) -> AnyView in
            return AnyView(Color.clear
            .preference(key: Key.self,
                        value: [proxy.frame(in: .global)]))
        })
    }
    
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
