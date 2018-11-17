//
//  MMPlayer+Codable.swift
//  MMPlayerView
//
//  Created by Millman on 2018/11/15.
//

import Foundation
extension Data {
    func decodeObject<T: Decodable>() -> T? {
        do {
            let decode = JSONDecoder()
            return try decode.decode(T.self, from: self)
        } catch {
            return nil
        }        
    }
}
