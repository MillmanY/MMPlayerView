//
//  BaseNavigationController.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2017/8/23.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    var tabBar: UITabBar?
    
    deinit {
        print("BaseNavigationController deinit")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setOriginalColor()
    }
    
    func setOriginalColor() {
        let barColor = UIColor.init(red: 0/255, green: 77/255, blue: 64/255, alpha: 1.0)
        self.setBarColor(color: barColor)
    }
    func setNavBarClear() {
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.isTranslucent = true
        self.navigationBar.barTintColor = UIColor.clear
    }
    
    func setLeft(items: [UIBarButtonItem]) {
        self.visibleViewController?.navigationItem.leftBarButtonItems = items
    }
    
    func setRight(items: [UIBarButtonItem]) {
        self.visibleViewController?.navigationItem.rightBarButtonItems = items
    }
    
    func setBarColor(color: UIColor){
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = color
    }
}

extension BaseNavigationController {
    func setBackAction() {
        
        self.setLeft(items: [UIBarButtonItem(image: #imageLiteral(resourceName: "ic_keyboard_arrow_left"),
                                             sel: #selector(backAction),
                                             tintColor: UIColor.white,
                                             target: self)])
    }

    func backAction() {
        if self.presentingViewController != nil && self.viewControllers.count == 1 {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.popViewController(animated: true)
        }
    }
}


extension UIBarButtonItem {
    
    convenience init(image: UIImage,sel: Selector,tintColor: UIColor?,target: AnyObject) {
        self.init()
        let btn = UIButton(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
        btn.backgroundColor = UIColor.clear
        btn.adjustsImageWhenHighlighted = false
        btn.addTarget(target, action: sel, for: .touchUpInside)
        btn.setImage(image, for: .normal)
        btn.imageView?.image = btn.imageView?.image?.withRenderingMode(.alwaysTemplate)
        btn.imageView?.tintColor = (tintColor != nil) ? tintColor! : UIColor.white
        self.customView = btn
    }
}

