//
//  PresentPlayerModifier.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/21.
//

import Foundation
import SwiftUI

extension View {
    public func present(isPresent: Binding<Bool> = .constant(false)) -> some View {
        return self.modifier(PresentPlayerModifier(isPresent: isPresent))
    }
    
}

struct PresentPlayerModifier: ViewModifier {
    @Binding var isPresent: Bool
    public func body(content: Content) -> some View {
        content
    }
}
