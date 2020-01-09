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
    static let listEdge = EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    let objs = DemoSource.shared.demoData.enumerated().map({ $0 })
    let control = MMPlayerControl()
    @State var currentIdx = -1
    var body: some View {
        ZStack(alignment: .top) {
            List {
                ForEach(objs, id: \.element.title) { (offset, element) in
                    PlayCellView(control: self.control,
                                 obj: element,
                                 isCurrent: offset == self.currentIdx)
                    .modifier(ListObserver(index: offset))
                }
                .listRowInsets(PlayerListView.listEdge)
            }
            .onPreferenceChange(ListObserver.ListFrameIndexPreferenceKey.self, perform: { (value) in
                let first = value.sorted { $0.frame.origin.y < $1.frame.origin.y }
                    .first { $0.frame.origin.y > 0 }
                if let f = first, f.idx != self.currentIdx  {
                    self.control.set(url: self.objs[f.idx].element.play_Url)
                    self.control.resume()
                    self.currentIdx = f.idx
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
