//
//  MMPlayer+String+Base64.swift
//  MMPlayerView
//
//  Created by Millman on 2018/11/16.
//

import Foundation
import UIKit
extension String {
    var base64Reverse: String? {
        get {
            guard let d = Data.init(base64Encoded: self) else {
                return nil
            }
            return String.init(data: d, encoding: .utf8)
        }
    }
    
    var base64: String {
        get {
            return Data(self.utf8).base64EncodedString()
        }
    }
}

