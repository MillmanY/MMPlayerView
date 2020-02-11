//
//  MMPlayerViewBridge.swift
//  MMPlayerView
//
//  Created by Millman on 2020/2/4.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine
var count = 0
@available(iOS 13.0.0, *)
struct MMPlayerViewBridge: UIViewRepresentable {
//    @EnvironmentObject var control: MMPlayerControl
    let player: AVPlayer
    init (player: AVPlayer) {
        self.player = player
    }
    
    public func updateUIView(_ uiView: MMPlayerContainer, context: UIViewRepresentableContext<MMPlayerViewBridge>) {
    }
    public func makeUIView(context: Context) -> MMPlayerContainer {
        count += 1
        print("Make #Bridge Count \(count)")
        return MMPlayerContainer(player: player)
    }
 
    static func dismantleUIView(_ uiView: MMPlayerContainer, coordinator: ()) {
        count -= 1
        print("#Dis Bridge Count \(count)")
        uiView.playerLayer.player = nil
    }
}
