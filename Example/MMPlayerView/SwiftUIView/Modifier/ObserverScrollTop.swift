//
//  ObserverScrollTop.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2020/1/15.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUI


struct TopIndexObserver: ViewModifier {
    struct Info {
        let idx: Int
        let frame: CGRect
    }
    @State var r: CGRect = .zero
    @Binding var info: TopIndexObserver.Info? 

    init(info: Binding<TopIndexObserver.Info?> = .constant(nil)) {
        self._info = info
    }
    
    
    func body(content: Content) -> some View {
        content
        .modifier(ObserverFrame(binding: $r))
        .onPreferenceChange(CellObserver.CellFrameIndexPreferenceKey.self, perform: { (value) in
            let sort = value.sorted { $0.frame.origin.y < $1.frame.origin.y }.filter {
                self.r.contains(CGPoint(x: $0.frame.midX, y: $0.frame.midY))
            }.sorted { $0.idx < $1.idx }.first
            if let s = sort {
                self.info = TopIndexObserver.Info.init(idx: s.idx, frame: s.frame)
            } else {
                self.info = nil
            }
        })
    }
}
