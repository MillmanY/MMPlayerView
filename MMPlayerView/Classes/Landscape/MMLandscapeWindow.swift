//
//  LandscapeWindow.swift
//  Pods
//
//  Created by Millman YANG on 2017/8/24.
//
//

import UIKit

private class WindowViewController: UIViewController {
    var isStatusHidden = false 
    
    override var prefersStatusBarHidden: Bool {
        return isStatusHidden
    }
}

public class MMLandscapeWindow: UIWindow {
    unowned let playerLayer: MMPlayerLayer
    weak var originalPlayView: UIView?
    var completed: (()->Void)?
    
    public init(playerLayer: MMPlayerLayer) {
        self.playerLayer = playerLayer
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.frame = UIScreen.main.bounds
        self.update()
    }
    
}

extension MMLandscapeWindow {
    private func setup() {
        self.rootViewController = WindowViewController()
        self.backgroundColor = UIColor.clear
 
    }

    func update() {
        switch self.playerLayer.orientation {
        case .protrait:
            (self.rootViewController as? WindowViewController)?.isStatusHidden = false
            if let o = self.originalPlayView {
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.rootViewController?.view.layer.transform = CATransform3DIdentity
                    self.rootViewController?.view.frame = o.superview?.convert(o.frame, to: self) ?? .zero
                }) { [weak self] (_) in
                    self?.playerLayer.playView = o
                    self?.originalPlayView = nil
                    self?.isHidden = true
                }
            }
        case .landscapeRight, .landscapeLeft:
            (self.rootViewController as? WindowViewController)?.isStatusHidden = true
            if !self.isPlayOnSelf {
                self.isHidden = false
                self.originalPlayView = self.playerLayer.playView
                self.makeKeyAndVisible()
                self.playerLayer.playView = self.rootViewController?.view
            }
            let parameter: CGFloat = UIDevice.current.orientation == .landscapeRight ? -1 : 1
            let isLand = UIScreen.main.bounds.width > UIScreen.main.bounds.height
            UIView.animate(withDuration: 0.3) {
                if !isLand {
                    let transform = CATransform3DRotate(CATransform3DIdentity, parameter*CGFloat.pi/2, 0, 0, 1)
                    self.rootViewController?.view.layer.transform = transform
                } else {
                    self.rootViewController?.view.layer.transform = CATransform3DIdentity
                }
                self.rootViewController?.view.frame = UIScreen.main.bounds
            }
        }
    }
    
    private var isPlayOnSelf: Bool {
        return self.playerLayer.playView == self.rootViewController?.view
    }
}
