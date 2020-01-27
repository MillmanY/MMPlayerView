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
class PlayListViewModel: ObservableObject {
    let videoList = DemoSource.shared.demoData

    private var debounceCancel: AnyCancellable?
    let debounceIdx = CurrentValueSubject<Int, Never>(0)
    
    @Published
    private(set) var currentViewIdx = -1
    

    unowned let control: MMPlayerControl
    
    var currentSelectObj: DataObj {
        return videoList[currentViewIdx]
    }
    
    init(control: MMPlayerControl) {
        self.control = control
        debounceCancel = debounceIdx.map({[weak self] (value) -> Int in
            guard let self = self else {return -1}
            self.currentViewIdx = value
            return value
        }).debounce(for: .seconds(2), scheduler: DispatchQueue.main).sink { [weak self] (idx) in
            guard let self = self, idx >= 0 else {return}
            control.set(url: self.videoList[idx].play_Url)
            control.resume()
            
        }
    }
    
    func updatePlayView(idx: Int) {
        self.control.invalidate()
        debounceIdx.value = idx
    }
    func updatePlayIdx() {
        self.control.invalidate()
        debounceIdx.value = debounceIdx.value+1
    }
}
