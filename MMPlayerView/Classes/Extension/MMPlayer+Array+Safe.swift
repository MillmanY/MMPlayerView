//
//  MMPlayer+Array+Safe.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/18.
//

import Foundation
extension Array {
    subscript(safe idx: Int) -> Element? {
        return indices ~= idx ? self[idx] : nil
    }
}
