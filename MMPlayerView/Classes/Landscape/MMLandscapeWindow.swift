//
//  LandscapeWindow.swift
//  Pods
//
//  Created by Millman YANG on 2017/8/24.
//
//

import UIKit

public class MMLandscapeWindow: UIWindow {
    
    public static let shared =  MMLandscapeWindow()
    weak var currentPlayLayer: MMPlayerLayer?
    weak var originalPlayView: UIView?
    weak var originalWindow:UIWindow?
    lazy var tempView: UIView = {
        return UIView()
    }()
    var completed: (()->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public func makeKey(root: UIViewController, playLayer: MMPlayerLayer, completed: (()-> Void)?) {
        
        if self.isKeyWindow {
            return
        }
        currentPlayLayer = playLayer
        originalPlayView = playLayer.playView
        self.rootViewController = root
        self.currentPlayLayer?.clearURLWhenChangeView = false
        currentPlayLayer?.playView = root.view
        self.completed = completed
        self.makeKeyAndVisible()
    }
    
    public func makeDisable() {
        originalWindow?.makeKeyAndVisible()
        tempView.removeFromSuperview()
        originalPlayView = nil
        currentPlayLayer = nil
        self.completed = nil
        self.rootViewController = nil
        originalWindow = nil
        self.isHidden = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func becomeKey() {
        super.becomeKey()
        self.backgroundColor = UIColor.clear
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        
        
        switch UIDevice.current.orientation {
        case .landscapeRight, .landscapeLeft:
            self.rootViewController?.view.frame = UIScreen.main.bounds
            break
        case .portrait:
            let convertR = originalPlayView?.superview?.frame ?? .zero
            let frame = originalPlayView?.superview?.convert(convertR, to: nil) ?? .zero
            self.rootViewController?.view.frame = frame
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [unowned self] in
                self.currentPlayLayer?.playView = self.originalPlayView
                self.currentPlayLayer?.clearURLWhenChangeView = true
                self.makeDisable()
                self.completed?()
            })
        default:
            break
        }
        UIViewController.attemptRotationToDeviceOrientation()
    }
}
