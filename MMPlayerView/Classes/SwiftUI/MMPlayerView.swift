//
//  MMPlayerView.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/24.
//

import SwiftUI

@available(iOS 13.0.0, *)
public struct MMPlayerViewUI: UIViewRepresentable {
    private let container = UIView()
    private let player: MMPlayerLayer
    
    public init(player: MMPlayerLayer) {
        self.player = player
        player.playView = container
    }
    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<MMPlayerViewUI>) {

    }
    public func makeUIView(context: Context) -> UIView {
        return container
    }
    
    public func set(url: URL?) -> Self {
        player.set(url: url)
        return self
    }
    
    public func resume() -> Self {
        player.resume()
        return self
    }
}

//@available(iOS 13.0.0, *)
//struct MMPlayerViewUI_Previews: PreviewProvider {
//    let player = MMPlayerLayer()
//    @available(iOS 13.0.0, *)
//    static var previews: some View {
//        MMPlayerViewUI(player: player)
//            .set(url: URL.init(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"))
//        .resume()
//        .previewLayout(.fixed(width: 375, height: 200))
//    }
//}
