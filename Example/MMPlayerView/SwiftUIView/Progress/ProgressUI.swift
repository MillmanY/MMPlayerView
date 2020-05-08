//
//  ProgressUI.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2020/1/31.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
@available(iOS 13.0.0, *)
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
        @Published
        var barFrame: (width: CGFloat?, height: CGFloat?)
    }
}
@available(iOS 13.0.0, *)
struct ProgressUI: View {
    enum BarType {
        case circle
        case bar
    }
    let type: BarType
    @ObservedObject var status = Status()
    var body: some View {
        self.generate()
    }
    
    func generate() -> AnyView {
        switch self.type {
        case .bar:
            let view = GeometryReader { (proxy) in
                ZStack(alignment: .leading) {
                    Rectangle().foregroundColor(self.status.tint)
                    Rectangle().foregroundColor(self.status.display)
                        .animation(.default)
                        .frame(width: (self.status.barFrame.width ?? proxy.size.width) * self.status.progress)
                }
                .frame(width: self.status.barFrame.width, height: self.status.barFrame.height)
                .cornerRadius(self.status.radius ?? proxy.size.height/2)
            }
            return AnyView(view)
        case .circle:
            let view = GeometryReader { (proxy) in
                ZStack(alignment: .leading) {
                    Circle().stroke(lineWidth: self.status.barFrame.width ?? 1).foregroundColor(self.status.tint)
                    Circle().trim(from: 0, to: self.status.progress).stroke(lineWidth: self.status.barFrame.width ?? 1).foregroundColor(self.status.display)
                        .animation(.default)
                }
                .rotationEffect(Angle.degrees(-90))
                .scaledToFit()
                .cornerRadius(self.status.radius ?? proxy.size.height/2)
            }
            return AnyView(view)
        }
    }
    
    init(circleWidth: CGFloat) {
        self.type = .circle
        status.barFrame = (width: circleWidth, height: nil)
    }
    
    init(barWidth: CGFloat, barHeight: CGFloat) {
        self.type = .bar
        status.barFrame = (barWidth, barHeight)
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
#if DEBUG
@available(iOS 13.0.0, *)
struct ProgressUI_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressUI.init(barWidth: 200, barHeight: 10)
                .value(0.5)
                .frame(width: 200, height: 20)
                .previewLayout(.fixed(width: 375, height: 44))

        }
    }
}
#endif
