//
//  MMPlayerProgressUI.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/6.
//

import Foundation
import SwiftUI
public struct MMPlayerProgressUI<Content>: View where Content: ProgressUIProtocol & View {
    public let content: Content
    @Binding var isStart: Bool

    public var body: some View {    
        content.start(isStart: isStart)
    }
}

public struct Test: View, ProgressUIProtocol {
    public var body: some View {
        EmptyView()
    }
    public init() {}
    public func start(isStart: Bool) -> some View {
        return isStart ? Color.red : Color .blue
    }

}

struct IndicatorBridge: UIViewRepresentable, ProgressUIProtocol {
    let i = UIActivityIndicatorView()
    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<IndicatorBridge>) {
    
    }

    public func makeUIView(context: Context) -> UIView {
        i.style = .large
        i.color = .white
        i.hidesWhenStopped = true
        return i
    }
    
    public func start(isStart: Bool) -> some View {
        if isStart {
            i.startAnimating()
        } else {
            i.stopAnimating()
        }
        return self
    }
}
