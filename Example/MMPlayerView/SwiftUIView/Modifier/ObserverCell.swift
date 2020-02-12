//
//  ObserverCell.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2020/1/15.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUI
import MMPlayerView
struct CellPlayerFramePreference: ViewModifier {
    let index: Int
//    @Binding var frame: CGRect
    func body(content: Content) -> some View {
            content
            .background(GeometryReader{ (proxy) in
                Color.clear
                .preference(key: Key.self,
                            value: [Key.Info(idx: self.index, frame: proxy.frame(in: .global))])
            })
//            .onPreferenceChange(Key.self) { (value) in
//                if let f = value.first {
//                    self.frame = f.frame
//                }
//            }
    }
    
    struct Key: PreferenceKey, Equatable {
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


struct CellPlayerVisiblePreference: ViewModifier {
    @State var r: CGRect = .zero
    @Binding var list: [CellPlayerFramePreference.Key.Info]
    init(list: Binding<[CellPlayerFramePreference.Key.Info]> = .constant([CellPlayerFramePreference.Key.Info]())) {
        self._list = list
    }
    
    func body(content: Content) -> some View {
        content.background(GeometryReader{ (proxy) in
                Color.clear.preference(key: Key.self,
                            value: [proxy.frame(in: .global)])
            })
        .modifier(FrameModifier<CellPlayerVisiblePreference.Key>(rect: $r))
        .onPreferenceChange(CellPlayerFramePreference.Key.self, perform: { (value) in
            let sort = value.sorted { $0.frame.origin.y < $1.frame.origin.y }.filter {
                self.r.intersects($0.frame)
            }.sorted { $0.idx < $1.idx }
            self.list = sort
        })
    }
    
    struct Key: PreferenceKey, Equatable {
        static var defaultValue: [CGRect] = []
        static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
            let n = nextValue()
            if n.count > 0 {
                value.append(contentsOf: n)
            }
        }
    }
}
