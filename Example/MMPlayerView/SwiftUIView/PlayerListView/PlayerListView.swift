//
//  PlayerListView.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2019/12/24.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftUI
import MMPlayerView
import Combine
struct PlayerListView: View {
    @ObservedObject var playListViewModel: PlayListViewModel
    let control: MMPlayerControl

    init() {
        self.control = MMPlayerControl()
        playListViewModel = PlayListViewModel.init(control: self.control)
    }
    
    static let listEdge = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    var body: some View {
        let objs = playListViewModel.videoList.enumerated().map({ $0 })

        return ZStack(alignment: .top) {
            List {
                ForEach(objs, id: \.element.title) { (offset, element) in
                    PlayCellView(control: self.control,
                                 obj: element,
                                 isCurrent: offset == self.playListViewModel.currentViewIdx)
                    .modifier(ListObserver(index: offset))
                }
                .listRowInsets(PlayerListView.listEdge)
            }
            .onPreferenceChange(ListObserver.ListFrameIndexPreferenceKey.self, perform: { (value) in
                let first = value.sorted { $0.frame.origin.y < $1.frame.origin.y }
                    .first { $0.frame.origin.y > 0 }
                if let f = first, f.idx != self.playListViewModel.currentViewIdx  {
                    print("Current Inidex \(f.idx)")
                    self.playListViewModel.updatePlayView(idx: f.idx)
                }
              })
        }
       .navigationBarTitle("Swift UI Demo", displayMode: .inline)
    }
}

struct PlayerListView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerListView()
    }
}


