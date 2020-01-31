//
//  ProgressUI.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2020/1/31.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
extension ProgressUI {
    class Status: ObservableObject {
        static let defaultColor = Color.blue
        @Published
        var tint: Color = defaultColor.opacity(0.3)
        @Published
        var display: Color = defaultColor
        @Published
        var radius: CGFloat?

        @Published
        var progress: CGFloat = 0.0
    }
}
struct ProgressUI: View {
    @ObservedObject var status = Status()
    var body: some View {
        GeometryReader { (proxy) in
            ZStack(alignment: .leading) {
                Rectangle().foregroundColor(self.status.tint)
            
                Rectangle().foregroundColor(self.status.display)
                    .animation(.default)
                    .frame(width: proxy.size.width * self.status.progress)
            }.cornerRadius(self.status.radius ?? proxy.size.height/2)
        }
    }
   
    func value(_ value: Double) -> ProgressUI {
        status.progress = CGFloat(value)
        return self
    }
    
    func radius(r: CGFloat) -> ProgressUI {
        status.radius = r
        return self
    }
    
    func progress(tint: Color?, display: Color?) -> ProgressUI {
        if let t = tint {
            status.tint = t
        }
        if let d = display {
            status.display = d
        }
        return self
    }

}

struct ProgressUI_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressUI()
                .value(0.5)
                .frame(width: 200, height: 20)
                .previewLayout(.fixed(width: 375, height: 44))
            
        }
    }
}
