//
//  TransitionDefine.swift
//  ETNews
//
//  Created by Millman YANG on 2017/5/22.
//  Copyright © 2017年 Sen Informatoin co. All rights reserved.
//

import Foundation

public protocol Config {
    var duration : TimeInterval { get set }
    weak var passOriginalSuper: UIView? {set get}
    weak var playLayer: MMPlayerLayer? { set get}
}

public protocol PresentConfig: Config {
    var margin: CGFloat { set get }
    weak var source: UIViewController? { set get }
}

public protocol NavConfig: Config {
}

public protocol TransitionCompatible {
    associatedtype CompatibleType
    static var mmPlayerTransition: MMTransition<CompatibleType>.Type { get set }
    
    var mmPlayerTransition: MMTransition<CompatibleType> { get set }
}

extension TransitionCompatible {
    public static var mmPlayerTransition: MMTransition<Self>.Type {
        get {
            return MMTransition<Self>.self
        } set {}
    }
    
    public var mmPlayerTransition: MMTransition<Self> {
        get {
            return MMTransition(self)
        } set {}
    }
}

public struct MMTransition<T> {
    public let base:T
    init(_ base: T) {
        self.base = base
    }
}

extension NSObject: TransitionCompatible { }

@objc public protocol MMPlayerFromProtocol {
    var passPlayer: MMPlayerLayer { get }
    func transitionWillStart()
    func transitionCompleted()
    
    func presentedView(isShrinkVideo: Bool)
    @objc optional func backReplaceSuperView(original: UIView?) -> UIView?
}

@objc public protocol MMPLayerToProtocol {
    var containerView: UIView { get }
    func completed()
}
