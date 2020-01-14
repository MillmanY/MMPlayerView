//
//  ObserverFrame.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2019/12/27.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUI

struct ListObserver: ViewModifier {
    let index: Int
    func body(content: Content) -> some View {
        content.background(GeometryReader{ proxy -> AnyView in
           return AnyView(Color.clear
            .preference(key: ListFrameIndexPreferenceKey.self,
                        value: [ListFrameIndexPreferenceKey.Info(idx: self.index, frame: proxy.frame(in: .global))]))
        })
    }
}

extension ListObserver {
    struct ListFrameIndexPreferenceKey: PreferenceKey, Equatable {
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
