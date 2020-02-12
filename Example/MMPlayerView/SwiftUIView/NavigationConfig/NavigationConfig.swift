//
//  NavigationConfig.swift
//  MMPlayerView_Example
//
//  Created by Millman on 2020/1/21.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUI
struct NavigationConfig: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfig>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfig>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}

extension View {
    public func navigationBarConfig(config: @escaping (UINavigationController) -> Void) -> some View {
        return self.background(NavigationConfig.init(configure: config))            
    }
}
