//
//  DetailViewController.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2017/8/23.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import MMPlayerView
class DetailViewController: UIViewController {
    var data: DataObj?
    fileprivate var playerLayer: MMPlayerLayer?
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var playerContainer: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        (self.navigationController as? BaseNavigationController)?.setBackAction()
        
        if let d = data {
            self.title = d.title
            textView.text = d.content
        }
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (self.navigationController as? BaseNavigationController)?.setNavBarClear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (self.navigationController as? BaseNavigationController)?.setOriginalColor()
    }}

extension DetailViewController: MMPLayerToProtocol {
    var containerView: UIView {
        get {
            return playerContainer
        }
    }

    
    func completed() {
        
    }
//    var containerView: UIView {
//        return playerContainer
//    }
//    
//    func transitionWillStart(passView: UIView) {
//        self.playerLayer = passView.mmPlayerLayer()
//    }
//    func transitionCompleted(passView: UIView) {
//        NSLayoutConstraint.deactivate(passView.constraints)
//        
//        playerContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": passView]))
//        playerContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": passView]))
//        
//    }
}
