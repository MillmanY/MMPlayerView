//
//  AppDelegate+Load.swift
//  Pods
//
//  Created by Millman YANG on 2017/8/26.
//
//
import Foundation
import UIKit

extension UIApplication {
    
    private static let runOnce: Void = {
        UIView.replaceFrameVar()
    }()
    
    override open var next: UIResponder? {
        // Called before applicationDidFinishLaunching
        UIApplication.runOnce
        return super.next
    }
}
