//
//  MMPlayerViewBridge.swift
//  MMPlayerView
//
//  Created by Millman on 2020/2/4.
//

import Foundation
import SwiftUI
import Combine
@available(iOS 13.0.0, *)
struct MMPlayerViewBridge: UIViewRepresentable {
    @EnvironmentObject var control: MMPlayerControl
    
    public func updateUIView(_ uiView: MMPlayerContainer, context: UIViewRepresentableContext<MMPlayerViewBridge>) {
    }
    public func makeUIView(context: Context) -> MMPlayerContainer {
        return MMPlayerContainer(player: control.player)
    }
 
    static func dismantleUIView(_ uiView: MMPlayerContainer, coordinator: ()) {
            uiView.playerLayer.player = nil
    }
//    static func dismantleUIView(_ uiView: MMPlayerContainer, coordinator: MMPlayerViewBridge.Coordinator) {
//        uiView.playerLayer.player = nil
//    }
}
