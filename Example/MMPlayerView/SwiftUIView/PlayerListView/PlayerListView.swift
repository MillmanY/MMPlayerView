//
//  PlayerListView.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2019/12/24.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftUI
import MMPlayerView
@available(iOS 13.0.0, *)
struct PlayerListView: View {
    static let listEdge = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    let presentVC: UIViewController
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
    @State var topInfo = [CellPlayerFramePreference.Key.Info]() {
        didSet {
            if let new = topInfo.first(where: { $0.frame.origin.y > 0 }), new.idx != self.playListViewModel.currentViewIdx, showDetailIdx == nil {
                self.playListViewModel.updatePlayView(idx: new.idx)
            }
        }
    }

    init(vc: UIViewController) {
        self.presentVC = vc
        let c = MMPlayerControl()
        self.control = c
        playListViewModel = PlayListViewModel(control: c)
        UITableViewCell.appearance().selectionStyle = .none
    }
    @State var status: PlayerOrientation = .protrait
    @State var fromFrame = CGRect.zero
    var body: some View {
        let objs = playListViewModel.videoList.enumerated().map({ $0 })
        return ZStack {
            if showDetailIdx != nil {
                DetailView(obj: self.playListViewModel.videoList[showDetailIdx!], showDetailIdx: $showDetailIdx)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.playerTransition(view: MMPlayerViewUI(control: control) ,from: fromFrame))
                    .zIndex(1)
            }
            
            NavigationView {
                List {
                    ForEach(objs, id: \.element.title) { (offset, element) in
                        PlayCellView(obj: element, idx: offset, showDetailIdx: self.showDetailIdx) {
                            if let obj = self.topInfo.first(where: { $0.idx == offset }) {
                                withAnimation {
                                    self.fromFrame = obj.frame
                                    self.showDetailIdx = offset
                                }
                            }
                        }
                        .environmentObject(self.control)
                        .environmentObject(self.playListViewModel)
                    }
                    .listRowInsets(PlayerListView.listEdge)
                }
                .modifier(CellPlayerVisiblePreference(list: Binding<[CellPlayerFramePreference.Key.Info]>(get: {
                    self.topInfo
                }) {
                    self.topInfo = $0
                }))
                .navigationBarItems(leading: self.dismissView())
                .navigationBarTitle("Swift UI Demo", displayMode: .inline)
                .alert(item: self.$control.error) { (err) -> Alert in
                        Alert(title: Text("Error"),
                              message: Text(err.localizedDescription),
                            dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
        .environmentObject(control)
    }
    
    func dismissView() -> some View {
        return Button.init(action: {
            self.presentVC.dismiss(animated: true, completion: nil)
        }) {
            Image("ic_keyboard_arrow_left")
            .frame(width: 44, height: 44)
        }
    }
    
}
//
//struct PlayerListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayerListView.init {
//            
//        }
//    }
//}
