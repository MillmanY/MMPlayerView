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
extension PlayerListView {
    static let listEdge = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}
struct PlayerListView: View {
    @ObservedObject var playListViewModel: PlayListViewModel
    let control: MMPlayerControl
    @State private var showDetails = false
    @State var listRect = CGRect.zero
    init() {
        self.control = MMPlayerControl()
        playListViewModel = PlayListViewModel.init(control: self.control)
    }
    
    var body: some View {
        let objs = playListViewModel.videoList.enumerated().map({ $0 })

        return ZStack(alignment: .top) {
            List {
                ForEach(objs, id: \.element.title) { (offset, element) in
                    PlayCellView(control: self.control,
                                 obj: element,
                                 isCurrent: offset == self.playListViewModel.currentViewIdx)
                    .modifier(CellObserver(index: offset))
                }
                .listRowInsets(PlayerListView.listEdge)
            }
            .modifier(TopIndexObserver.init(completed: { (idx) in
                self.playListViewModel.updatePlayView(idx: idx)
                print("# idx \(idx)")
            }))
//            if showDetails {
//                DetailView(control: control)
//            }
////                .scaleEffect(showDetails ? 1.0 : 0.00001)
//            .position(x: 0, y: 0)
            Button.init("Check") {
                print(self.listRect)
            }

        }
       .navigationBarTitle("Swift UI Demo", displayMode: .inline)
    }
}

struct PlayerListView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerListView()
    }
}


