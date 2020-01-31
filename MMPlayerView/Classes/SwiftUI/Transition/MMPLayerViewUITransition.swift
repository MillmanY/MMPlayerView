//
//  MMPLayerViewUITransition.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/20.
//

import Foundation
import SwiftUI


public extension AnyTransition {
    static func playerTransition(from: CGRect?) -> AnyTransition {
        let f = from ?? .zero
        return AnyTransition.modifier(active: MMPlayerViewTransition(from: f, percent: 0.0),
                                      identity: MMPlayerViewTransition(from: f, percent: 1.0))
    }
}

struct MMPlayerViewTransition: AnimatableModifier {
    @EnvironmentObject var control: MMPlayerControl
    var animatableData: CGFloat {
        get {
            return percent
        } set {
            self.percent = newValue
        }
    }
    var percentSize: CGSize {
        let w =  (from.size.width-(from.size.width-to.size.width)*percent)/(from.size.width == 0 ? 1 : from.size.width)
        let h =  (from.size.height-(from.size.height-to.size.height)*percent)/(from.size.height == 0 ? 1 : from.size.height)
        return CGSize.init(width: w, height: h)
    }
    var percentOffsetX: CGFloat {
        return (from.midX-to.midX)*percent
    }
    
    var percentOffsetY: CGFloat {
        (from.midY-to.midY)*percent
    }
    
    let from: CGRect
    @State var to: CGRect = .zero
    var percent: CGFloat = 0
    init(from: CGRect, percent: CGFloat) {
        self.from = from
        self.percent = percent
    }
    func body(content: Content) -> some View {
        return ZStack {
            content.opacity(Double(percent))
                   .modifier(GlobalPlayerFrameModifier(rect: self.$to))
            GeometryReader { (proxy) in
                MMPlayerViewUI()
                .frame(width: self.from.size.width, height: self.from.size.height)
                .scaleEffect(self.percentSize)
                .offset(x: self.from.midX-proxy.size.width/2-self.percentOffsetX,
                        y: self.from.midY-proxy.size.height/2-self.percentOffsetY)
                .opacity(self.percent == 1.0 ? 0 : 1)
            }.edgesIgnoringSafeArea(.all)
        }
    }
}
