//
//  PlayCellView.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2019/12/24.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftUI
import MMPlayerView

struct PlayCellView: View {
    @EnvironmentObject var control: MMPlayerControl
    @State var downloadStatus: MMPlayerDownloader.DownloadStatus = .none
    let obj: DataObj
    let player: MMPlayerViewUI?
    init(player: MMPlayerViewUI?, obj: DataObj) {
        self.player = player
        self.obj = obj
    }

    var body: some View {
        return VStack {
            ZStack {
                Image(uiImage: self.obj.image ?? UIImage())
                    .resizable()
                    .frame(height: 200)
                player
            }
            HStack {
                Text(self.obj.title)
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                Spacer()
                self.generateTopViewFromDownloadStatus().frame(width: 50, height: 50).padding(10)
            }
        }
        .modifier(MMPlayerDownloaderModifier( url: obj.play_Url!, status: $downloadStatus))
    }
    
    func generateTopViewFromDownloadStatus() -> AnyView {
        switch self.downloadStatus {
        case .downloading(let value):
            let percent = String.init(format: "%.2f ％", value*100)
            let view = ZStack {
                ProgressUI(circleWidth: 5)
                .value(Double(value))
                Text(percent).foregroundColor(Color.blue).scaledToFit().padding(5).minimumScaleFactor(0.5)
            }
            return AnyView(view)

        default:
            return AnyView(EmptyView())
        }
    }

    
}

struct PlayCellView_Previews: PreviewProvider {
    static var previews: some View {
        PlayCellView(player: MMPlayerViewUI.init(control: MMPlayerControl()) ,obj: DemoSource.shared.demoData[2])
            .previewLayout(.sizeThatFits)
    }
}


struct GlobalFrameHandler: View {
    let block: ((CGRect)->Void)
    var body: some View {
        GeometryReader.init { (proxy) -> AnyView  in
            let proxyF = proxy.frame(in: .global)
            DispatchQueue.main.async {
                self.block(proxyF)
            }
            return AnyView(EmptyView())
        }
    }
}


