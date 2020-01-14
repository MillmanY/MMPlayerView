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
    let control: MMPlayerControl
    var body: some View {
            MMPlayerViewUI(cover: CoverAUI(), control: self.control)

    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
