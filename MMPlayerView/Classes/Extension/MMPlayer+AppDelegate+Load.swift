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
    
    private static let mmPlayerRunOnce: Void = {
        UIView.replaceFrameVar()
    }()
    
    override open var next: UIResponder? {
        // Called before applicationDidFinishLaunching
        UIApplication.mmPlayerRunOnce
        return super.next
    }
}
