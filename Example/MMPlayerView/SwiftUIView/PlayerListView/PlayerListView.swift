//
//  PlayerListView.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2019/12/24.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftUI
import MMPlayerView

struct PlayTransition: ViewModifier {
    func body(content: Content) -> some View {
        return content
    }
}

extension PlayerListView {
    static let listEdge = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}
struct PlayerListView: View {
    @ObservedObject var control: MMPlayerControl
    @ObservedObject var playListViewModel: PlayListViewModel
    @State var showDetails = false
    @State var topInfo: TopIndexObserver.Info? {
        didSet {
            if let new = topInfo?.idx, new != oldValue?.idx {
                self.playListViewModel.updatePlayView(idx: new)
            }
        }
    }

    init() {
        let c = MMPlayerControl()
        self.control = c
        playListViewModel = PlayListViewModel.init(control: c)
    }
     
    var body: some View {
        let objs = playListViewModel.videoList.enumerated().map({ $0 })
        return ZStack {
            if showDetails {
                DetailView(obj: self.playListViewModel.currentSelectObj, control: control)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.playerTransition(from: topInfo?.frame))
                    .zIndex(1)
            }
            
            NavigationView {
                List {
                    ForEach(objs, id: \.element.title) { (offset, element) in
                        PlayCellView(control: self.control,
                                     obj: element,
                                     isCurrent: offset == self.playListViewModel.currentViewIdx)
                            .modifier(CellObserver(index: offset))
                    }
                    .listRowInsets(PlayerListView.listEdge)
                }
                .modifier(TopIndexObserver(info: Binding<TopIndexObserver.Info?>(get: {
                        self.topInfo
                    }) {
                        self.topInfo = $0
                    }))
                .alert(item: self.$control.error) { (err) -> Alert in
                        Alert(title: Text("Error"),
                              message: Text(err.localizedDescription),
                            dismissButton: .default(Text("OK"))
                    )
                }
                .navigationBarTitle("Swift UI Demo", displayMode: .inline)
                .navigationBarConfig(config: { (nav) in
                    nav.navigationBar.barTintColor = UIColor(red: 0/255, green: 77/255, blue: 64/255, alpha: 1.0)
                })
            }

            Button(action: {
                     withAnimation {
                         self.showDetails.toggle()
                     }
                 }) {
                     Text("present").foregroundColor(.blue)
            }.zIndex(100)
        }
    }
}

struct PlayerListView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerListView()
    }
}
