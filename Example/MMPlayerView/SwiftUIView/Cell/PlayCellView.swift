//
//  PlayCellView.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2019/12/24.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftUI
import MMPlayerView
struct PlayCellView: View {
    let obj: DataObj
    let player: MMPlayerLayer
    
    init(obj: DataObj, player: MMPlayerLayer) {
        self.obj = obj
        self.player = player
    }
    var body: some View {
        VStack(alignment: .leading) {
            Image(uiImage: self.obj.image ?? UIImage())
                .resizable()
                .frame(height: 200)
                .background(Color.blue)
                .modifier(GlobalTopNotifyModifier.init(player:player, change: { (isTop) in
                    if isTop {
                        self.player.set(url: self.obj.play_Url)
                        self.player.resume()
                    } else {
                        self.player.invalidate()
                    }
                }))
            
            Text(self.obj.title)
                .multilineTextAlignment(.leading)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        }
    }
}

struct PlayCellView_Previews: PreviewProvider {
    static var previews: some View {
        PlayCellView(obj: DemoSource.shared.demoData[2], player: MMPlayerLayer())
            .previewLayout(.sizeThatFits)
   
    }
}

struct GlobalTopNotifyModifier: ViewModifier {
    @State var isViewTop: Bool = false
    let player: MMPlayerLayer
    let change: ((Bool)->Void)
    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { (proxy) in
                Run {
                    let f = proxy.frame(in: .global)
                    let area: CGFloat = 88.0
                    let will = f.origin.y-area < 0 && f.origin.y+f.size.height-area > 0
                    if will != self.isViewTop {
                        self.isViewTop = will
                        self.change(will)
                    }
                }
            }
            if isViewTop {
                MMPlayerViewUI(player: player)
            }
        }
    }
}

struct Run: View {
    let block: () -> Void
    var body: some View {
        DispatchQueue.main.async(execute: block)
        return AnyView(EmptyView())
    }
}
