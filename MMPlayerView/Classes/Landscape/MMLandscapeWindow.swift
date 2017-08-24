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
    weak var playView: UIView?
    weak var originalPlaySuperView: UIView?
    weak var originalWindow:UIWindow?
    var completed: (()->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public func makeKey(root: UIViewController, playLayer: MMPlayerLayer, completed:@escaping (()-> Void)) {
        if self.isKeyWindow {
            return
        }
        
        guard let p = playLayer.playView else {
            return
        }
        p.translatesAutoresizingMaskIntoConstraints = true
        playView = p
        originalPlaySuperView = playView?.superview
        root.view.addSubview(p)
        self.frame = UIScreen.main.bounds
        root.view.frame = UIScreen.main.bounds
        self.completed = completed
        self.rootViewController = root
        self.makeKeyAndVisible()
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    public func makeDisable() {
        originalWindow?.makeKeyAndVisible()
        self.completed = nil
        playView = nil
        originalPlaySuperView = nil
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
        
        guard let p = playView else {
            return
        }
        
        switch UIDevice.current.orientation {
        case .landscapeRight, .landscapeLeft:
            p.frame = self.bounds
        case .portrait:
            let convertR = originalPlaySuperView?.frame ?? .zero
            let frame = originalPlaySuperView?.convert(convertR, to: nil) ?? .zero
            p.frame = frame
            self.addSubview(p)
            self.rootViewController?.view.alpha = 0.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                self.playView?.translatesAutoresizingMaskIntoConstraints = false
                self.originalPlaySuperView?.addSubview(p)
                self.completed?()
                self.makeDisable()
            })
        default:
            break
        }
    }
    
}
