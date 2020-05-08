//
//  PlayerListViewModel.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2020/1/10.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Combine
import MMPlayerView
@available(iOS 13.0.0, *)
class PlayListViewModel: ObservableObject {
    let videoList = DemoSource.shared.demoData

    private var debounceCancel: AnyCancellable?
    let debounceIdx = CurrentValueSubject<Int, Never>(0)
    
    @Published
    private(set) var currentViewIdx = -1
    unowned let control: MMPlayerControl
    
    init(control: MMPlayerControl) {
        self.control = control
        debounceCancel = debounceIdx
        .filter({
            self.currentViewIdx != $0
        })
        .map({[weak self] (value) -> Int in
            guard let self = self else {return -1}
            self.currentViewIdx = value
            self.control.invalidate()
            return value
        }).debounce(for: .seconds(0.5), scheduler: DispatchQueue.main).sink { [weak self] (idx) in
            guard let self = self, idx >= 0 else {return}
            control.set(url: self.videoList[idx].play_Url)
            control.resume()
        }
    }
    
    func updatePlayView(idx: Int) {
        debounceIdx.value = idx
    }
}
