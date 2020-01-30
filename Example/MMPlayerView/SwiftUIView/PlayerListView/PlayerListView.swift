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
    @State var showDetailIdx: Int? = nil {
        didSet {
            if let s = self.showDetailIdx {
                if s != self.playListViewModel.currentViewIdx {
                    self.control.invalidate()
                }
                self.playListViewModel.updatePlayView(idx: s)
            }
        }
    }
    @State var topInfo = [CellObserver.CellFrameIndexPreferenceKey.Info]() {
        didSet {
            if let new = topInfo.first(where: { $0.frame.origin.y > 0 }), new.idx != oldValue.first?.idx, showDetailIdx == nil {
                self.playListViewModel.updatePlayView(idx: new.idx)
            }
        }
    }

    init() {
        let c = MMPlayerControl()
        self.control = c
        playListViewModel = PlayListViewModel(control: c)
    }
    
    var realFrame : CGRect {
        get {
            var f = self.topInfo.first(where: { $0.idx == showDetailIdx})?.frame ?? .zero
            f.size.height = 300
            return f
        }
    }
     
    var body: some View {
        let objs = playListViewModel.videoList.enumerated().map({ $0 })
        return ZStack {
            if showDetailIdx != nil {
                DetailView(obj: self.playListViewModel.videoList[showDetailIdx!], showDetailIdx: $showDetailIdx)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.playerTransition(from: realFrame))
                    .zIndex(1)
            }
            
            NavigationView {
                List {
                    ForEach(objs, id: \.element.title) { (offset, element) in
                        PlayCellView(obj: element,
                                     isCurrent: offset == self.playListViewModel.currentViewIdx)
                            .modifier(CellObserver(index: offset))
                            .onTapGesture {
                                withAnimation {
                                    self.showDetailIdx = offset
                                }
                        }
                    }
                    .listRowInsets(PlayerListView.listEdge)
                }
                .modifier(CellVisibleObserver(list: Binding<[CellObserver.CellFrameIndexPreferenceKey.Info]>(get: {
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
        }
        .environmentObject(control)
    }
}

struct PlayerListView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerListView()
    }
}
