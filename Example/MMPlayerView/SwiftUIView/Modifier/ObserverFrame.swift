//
//  ObserverFrame.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2019/12/27.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUI

struct ObserverFrame: ViewModifier {
    @Binding var r: CGRect
    init(binding: Binding<CGRect> = .constant(.zero)) {
        self._r = binding
    }
    func body(content: Content) -> some View {
        content.background(GeometryReader{ (proxy) in
            return Color.clear
            .preference(key: FrameIndexPreferenceKey.self,
                        value: [proxy.frame(in: .global)])
        }).onPreferenceChange(FrameIndexPreferenceKey.self) { (value) in
            guard let f = value.first, self.r != f else {return}
            self.r = f
        }
    }
}

extension ObserverFrame {
    struct FrameIndexPreferenceKey: PreferenceKey, Equatable {
        static var defaultValue: [CGRect] = []
        static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
            let n = nextValue()
            if n.count > 0 {
                value.append(contentsOf: n)
            }
        }
    }
}
