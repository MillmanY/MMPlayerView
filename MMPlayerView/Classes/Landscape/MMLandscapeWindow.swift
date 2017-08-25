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
    weak var playerLayer: MMPlayerLayer?
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
        self.makeKeyAndVisible()
//        guard let p = playLayer.playView else {
//            return
//        }
//        playLayer.clearURLWhenChangeView = false
        originalPlayView = playLayer.playView
        print(originalPlayView)
        
        self.playerLayer = playLayer
        playLayer.playView = root.view

        self.frame = UIScreen.main.bounds
        root.view.frame = UIScreen.main.bounds
        self.completed = completed
        self.rootViewController = root
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    public func makeDisable() {
        originalWindow?.makeKeyAndVisible()
        tempView.removeFromSuperview()
        originalPlayView = nil
        playerLayer = nil
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
        if !self.isKeyWindow {
            return
        }
        
        switch UIDevice.current.orientation {
        case .landscapeRight, .landscapeLeft:
            break
        case .portrait:
            let convertR = originalPlayView?.superview?.frame ?? .zero
            tempView.frame = originalPlayView?.superview?.convert(convertR, to: nil) ?? .zero
            playerLayer?.playView = tempView
            self.addSubview(tempView)
            self.rootViewController?.view.alpha = 0.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                self.tempView.removeFromSuperview()
                self.playerLayer?.playView = self.originalPlayView
                self.playerLayer?.clearURLWhenChangeView = true
                self.makeDisable()
                self.completed?()
            })
        default:
            break
        }
    }
    
}
