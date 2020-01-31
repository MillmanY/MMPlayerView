//
//  DetailView.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2020/1/10.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
import MMPlayerView
struct DetailView: View {
    let obj: DataObj
    @Binding var showDetailIdx: Int?
    var body: some View {
        VStack {

            ZStack(alignment: .topLeading) {
                MMPlayerViewUI().frame(height: 200)
                Image("ic_keyboard_arrow_left")
                    .offset(x: 15, y: 44)
                    .onTapGesture {
                        withAnimation {
                            self.showDetailIdx = nil
                        }
                }
            }
            ProgressUI()
                .value(0)
                .frame(width: 200, height: 10)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(obj.title).font(.title).bold()
                    Text(obj.content).font(.body)
                }
            }
            .padding([.leading , .trailing], 8)
        }.background(Color.white)
    }
}


struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView.init(obj: DemoSource.shared.demoData[1], showDetailIdx: .constant(nil))
        .environmentObject(MMPlayerControl())

    }
}
