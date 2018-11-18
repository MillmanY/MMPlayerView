//
//  WeakBox.swift
//  MMPlayerView
//
//  Created by Millman on 2018/11/18.
//

import Foundation
class WeakBox<T: AnyObject> {
    weak var value: T?
    
    init(_ value: T) {
        self.value = value
    }
}
