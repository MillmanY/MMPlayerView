//
//  CoverAUI.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2020/1/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
import MMPlayerView
import AVFoundation
struct CoverAUI: View {
    @EnvironmentObject var control: MMPlayerControl
    @State var scrollValue = 0.0
    @State var isSliderScroll: Bool = false
    var body: some View {
        let currentValue = Binding<Double>(get: { () -> Double in
            return self.isSliderScroll ? self.scrollValue : self.control.timeInfo.current.seconds
        }) {
            self.scrollValue = $0
        }
        return VStack {
            Spacer()
            Image(self.imageName).onTapGesture {
                self.playAction()
            }.foregroundColor(Color.white)
            Spacer()
            HStack {
                Image("fullscreen").foregroundColor(.white).padding(.leading, 15).onTapGesture {
                    switch self.control.orientation {
                    case .landscapeLeft, .landscapeRight:
                        self.control.orientation = .protrait
                    case .protrait:
                        self.control.orientation = .landscapeRight
                    }
                }

                Text(self.control.timeInfo.current.seconds.convertSecondString())
                    .font(Font.custom("Courier", size: 17))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                Slider(value: currentValue, in: 0...self.control.timeInfo.total.seconds) { (isScroll) in
                    self.isSliderScroll = true
                    if isScroll { return }
                    let time =  CMTimeMake(value: Int64(self.scrollValue), timescale: 1)
                    self.control.player.seek(to: time) { (value) in
                        self.isSliderScroll = false
                        self.control.toggleCoverShowStatus()
                    }
                }
                Text(self.control.timeInfo.willEndTime.seconds.convertSecondString())
                    .font(Font.custom("Courier", size: 17))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(.trailing, 15)
            }.frame(height: 44)
            .background(Color.black.opacity(0.25))
        }
    }
    
    private func playAction() {
        if self.control.player.rate == 0.0 {
            self.control.player.play()
        } else {
            self.control.player.pause()
        }
    }
    
    private var imageName: String {
        return control.player.rate == 0 ? "ic_play_circle_filled" : "ic_pause_circle_filled"
    }
}

struct CoverAUI_Previews: PreviewProvider {
    static var previews: some View {
        CoverAUI()
            .environmentObject(MMPlayerControl.init(player: AVPlayer()))
            .previewLayout(.fixed(width: 375, height: 300))
    }
}
