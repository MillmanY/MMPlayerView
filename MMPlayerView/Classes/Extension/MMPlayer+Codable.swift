//
//  MMPlayer+Codable.swift
//  MMPlayerView
//
//  Created by Millman on 2018/11/15.
//

import Foundation
extension Dictionary {
    func decodeObject<T: Decodable>() -> T? {
        if let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
            let obj = try? JSONDecoder().decode(T.self, from: data) {
            return obj
        }
        
        
        
        return nil
    }
}

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
