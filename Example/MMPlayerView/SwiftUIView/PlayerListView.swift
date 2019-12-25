//
//  PlayerListView.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2019/12/24.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftUI
import MMPlayerView
struct PlayerListView: View {
    let player = MMPlayerLayer()
    
    @State var offset = CGPoint.zero
    var body: some View {
        List {
            ForEach(DemoSource.shared.demoData, id: \.title) { (data) in
                PlayCellView.init(obj: data, player: self.player)
            }
            .listRowInsets(EdgeInsets(top: 0,
                                      leading: 0,
                                      bottom: 0,
                                      trailing: 0))
        }
        
        
    }
}

struct PlayerListView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerListView()
    }
}
