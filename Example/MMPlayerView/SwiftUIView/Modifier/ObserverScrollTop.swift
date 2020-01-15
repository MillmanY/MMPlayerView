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
    @State var r: CGRect = .zero
    @State var idx: Int? {
        didSet {
            if let idx = self.idx, idx != oldValue {
                self.index(idx)
            }
        }
    }
    let index: ((Int)->Void)
    init(completed: @escaping (Int)->Void) {
        self.index = completed
    }
    func body(content: Content) -> some View {
        content
        .modifier(ObserverFrame(binding: $r))
        .onPreferenceChange(CellObserver.CellFrameIndexPreferenceKey.self, perform: { (value) in
            let sort = value.sorted { $0.frame.origin.y < $1.frame.origin.y }.filter {
                self.r.contains(CGPoint(x: $0.frame.midX, y: $0.frame.midY))
            }.sorted { $0.idx < $1.idx }.first
            self.idx = sort?.idx
        })
    }
}
