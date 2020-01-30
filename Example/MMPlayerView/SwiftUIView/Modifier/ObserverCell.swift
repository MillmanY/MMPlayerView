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

struct CellVisibleObserver: ViewModifier {
    @State var r: CGRect = .zero
    @Binding var list: [CellObserver.CellFrameIndexPreferenceKey.Info]
    init(list: Binding<[CellObserver.CellFrameIndexPreferenceKey.Info]> = .constant([CellObserver.CellFrameIndexPreferenceKey.Info]())) {
        self._list = list
    }
    
    
    func body(content: Content) -> some View {
        content
        .modifier(ObserverFrame(binding: $r))
        .onPreferenceChange(CellObserver.CellFrameIndexPreferenceKey.self, perform: { (value) in
            let sort = value.sorted { $0.frame.origin.y < $1.frame.origin.y }.filter {
                self.r.intersects($0.frame)
//                self.r.contains(CGPoint(x: $0.frame.midX, y: $0.frame.midY))
            }.sorted { $0.idx < $1.idx }
            self.list = sort
        })
    }
}
