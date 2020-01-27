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
    let control: MMPlayerControl
    
    var body: some View {
////        MMPlayerViewUI(progress: CoverAUI(), control: self.control)
//        EmptyView()
        VStack {
            Spacer.init(minLength: 100)
            MMPlayerViewUI(control: control).frame(height: 300)
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


//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
