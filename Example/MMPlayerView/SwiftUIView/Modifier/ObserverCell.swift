//
//  ObserverCell.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2020/1/15.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUI


struct CellObserver: ViewModifier {
    let index: Int
    func body(content: Content) -> some View {
            content
            .background(GeometryReader{ (proxy) in
                Color.clear
                .preference(key: CellFrameIndexPreferenceKey.self,
                            value: [CellFrameIndexPreferenceKey.Info(idx: self.index,
                                                                     frame: proxy.frame(in: .global))])
      })
    }
}

extension CellObserver {
    struct CellFrameIndexPreferenceKey: PreferenceKey, Equatable {
        struct Info: Equatable {
            let idx: Int
            let frame: CGRect
            
            init(idx: Int, frame: CGRect) {
                self.idx = idx
                self.frame = frame
            }
        }
        static var defaultValue: [Info] = []
        static func reduce(value: inout [Info], nextValue: () -> [Info]) {
            value.append(contentsOf: nextValue())
        }
    }
}
