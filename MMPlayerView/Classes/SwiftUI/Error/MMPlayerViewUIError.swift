//
//  PlayUIError.swift
//  MMPlayerView
//
//  Created by Millman on 2020/1/17.
//

import Foundation
public struct MMPlayerViewUIError: Error ,Identifiable, Equatable {
    public enum ErrType {
        case loadFailed
    }
    public let id: ErrType
    let desc: String
    
    public init(id: ErrType, desc: String) {
        self.id = id
        self.desc = desc
    }
    
    public var localizedDescription: String {
        get {
            return desc
        }
    }
    
    public static func == (lhs: MMPlayerViewUIError, rhs: MMPlayerViewUIError) -> Bool {
        return lhs.id == rhs.id && lhs.desc == rhs.desc
    }

}
