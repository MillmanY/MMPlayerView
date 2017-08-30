//
//  TransitionDefine.swift
//  ETNews
//
//  Created by Millman YANG on 2017/5/22.
//  Copyright © 2017年 Sen Informatoin co. All rights reserved.
//

import Foundation

public protocol MMPlayerConfig {
    var duration : TimeInterval { get set }
    weak var passOriginalSuper: UIView? {set get}
    weak var playLayer: MMPlayerLayer? { set get}
}

public protocol MMPlayerPresentConfig: MMPlayerConfig {
    var margin: CGFloat { set get }
    var shrinkSize: CGSize { set get }
    var dismissGesture: Bool { get }
    weak var source: UIViewController? { set get }
}

public protocol MMPlayerNavConfig: MMPlayerConfig {
}

public protocol MMPlayerTransitionCompatible {
    associatedtype CompatibleType
    static var mmPlayerTransition: MMPlayerTransition<CompatibleType>.Type { get set }
    
    var mmPlayerTransition: MMPlayerTransition<CompatibleType> { get set }
}

extension MMPlayerTransitionCompatible {
    public static var mmPlayerTransition: MMPlayerTransition<Self>.Type {
        get {
            return MMPlayerTransition<Self>.self
        } set {}
    }
    
    public var mmPlayerTransition: MMPlayerTransition<Self> {
        get {
            return MMPlayerTransition(self)
        } set {}
    }
}

public struct MMPlayerTransition<T> {
    public let base:T
    init(_ base: T) {
        self.base = base
    }
}

extension NSObject: MMPlayerTransitionCompatible { }

@objc public protocol MMPlayerPrsentFromProtocol: MMPlayerFromProtocol {
    
    func presentedView(isShrinkVideo: Bool)
    func dismissViewFromGesture()
}

@objc public protocol MMPlayerFromProtocol {
    var passPlayer: MMPlayerLayer { get }
    func transitionWillStart()
    func transitionCompleted()
    @objc optional func backReplaceSuperView(original: UIView?) -> UIView?
}

@objc public protocol MMPLayerToProtocol {
    var containerView: UIView { get }
    func transitionCompleted()
}
