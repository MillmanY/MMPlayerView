//
//  OrientationObserver.swift
//  MMPlayerView
//
//  Created by Millman on 2020/2/5.
//

import Foundation
import Combine
import SwiftUI
@available(iOS 13.0, *)
class OrientationObserver: ObservableObject {
    @Published var enable = false
    @Published public var orientation: PlayerOrientation = OrientationObserver.convert()
    init() {
        
        
    }
    
    func startObserver() {
        self.enable = true
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { (_) in
            switch UIDevice.current.orientation {
            case .landscapeLeft:
                self.orientation = .landscapeLeft
            case .landscapeRight:
                self.orientation = .landscapeRight
            case .portrait:
                self.orientation = .protrait
            default: break
            }
        }
    }
    
    static func convert() -> PlayerOrientation {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return .protrait
        }

    }
}

@available(iOS 13.0, *)
struct OrientationModifier: ViewModifier {
    let status = OrientationObserver()
    var cancelAble: AnyCancellable?
    public func body(content: Content) -> Content {
        content
    }
    
    init(orientation: Binding<PlayerOrientation> = .constant(.protrait)) {
        cancelAble = self.status.$orientation.sink {
            orientation.wrappedValue = $0
        }
    }
    init(orientation: @escaping ((PlayerOrientation)->Void)) {
        cancelAble = self.status.$orientation.sink {
            orientation($0)
        }
    }
}
