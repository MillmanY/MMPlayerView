//
//  MMPLayerViewUITransition.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/20.
//

import Foundation
import SwiftUI

@available(iOS 13.0.0, *)
public extension AnyTransition {
    static func playerTransition<Content: View>(view: Content, from: CGRect?) -> AnyTransition {
        let f = from ?? .zero
        return AnyTransition.modifier(active: ViewTransition(pass: view, from: f, percent: 0.0),
                                      identity: ViewTransition(pass: view, from: f, percent: 1.0))
    }
}

@available(iOS 13.0.0, *)
struct ViewTransition<PassView>: AnimatableModifier where PassView: View {
    
    @EnvironmentObject var control: MMPlayerControl
    @State var to: CGRect = .zero
    
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
    var percent: CGFloat = 0
    let pass: PassView
    
    init(pass: PassView, from: CGRect, percent: CGFloat) {
        self.from = from
        self.percent = percent
        self.pass = pass
    }
    
    func body(content: Content) -> some View {
        return ZStack {
            
            content.opacity(Double(percent)).modifier(FrameModifier<TransitionFramePreference.Key>(rect: $to))
            GeometryReader { (proxy) in
                self.pass
                .frame(width: self.from.size.width, height: self.from.size.height)
                .scaleEffect(self.percentSize)
                .offset(x: self.from.midX-proxy.size.width/2-self.percentOffsetX,
                        y: self.from.midY-proxy.size.height/2-self.percentOffsetY)
                .opacity(self.percent == 1.0 ? 0 : 1)
            }.edgesIgnoringSafeArea(.all)
        }
    }
}

