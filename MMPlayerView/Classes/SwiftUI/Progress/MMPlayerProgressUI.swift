//
//  MMPlayerProgressUI.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/6.
//

import Foundation
import SwiftUI
@available(iOS 13.0.0, *)
public struct DefaultIndicator: View {
    @EnvironmentObject var control: MMPlayerControl
    public var body: some View {
        return control.isLoading ? AnyView(IndicatorBridge()) : AnyView(EmptyView())
    }
    
    struct IndicatorBridge: UIViewRepresentable {
        public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<IndicatorBridge>) {
        }
        public func makeUIView(context: Context) -> UIView {
            let i = UIActivityIndicatorView()
            i.startAnimating()
            i.style = .large
            i.color = .white
            i.hidesWhenStopped = true
            return i
        }
    }
}
