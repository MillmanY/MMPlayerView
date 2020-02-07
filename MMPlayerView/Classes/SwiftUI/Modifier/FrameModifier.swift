//
//  FrameModifier.swift
//  MMPlayerView
//
//  Created by Millman on 2020/2/7.
//

import Foundation
import SwiftUI
@available(iOS 13.0.0, *)
public struct FrameModifier<K: PreferenceKey>: ViewModifier where K.Value == [CGRect] {
    @Binding var r: CGRect
    public init (rect: Binding<CGRect> = .constant(.zero)) {
        self._r = rect
    }
    public func body(content: Content) -> some View {
        content.onPreferenceChange(K.self) { (values) in
            if let f = values.first, f != .zero {
                DispatchQueue.main.async {
                    self.r = f
                }
            }
        }
    }
}
