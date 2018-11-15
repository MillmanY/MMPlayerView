//
//  MMPlayerDownLoadVideoInfo.swift
//  MMPlayerView
//
//  Created by Millman on 2018/11/15.
//

import Foundation
public struct MMPlayerDownLoadVideoInfo: Codable {
    let url: URL
    let type: VideoType
    let fileName: String
    let fileSubPath: String
    
    var localURL: URL {
        get {
            return URL.init(fileURLWithPath: VideoBasePath)
                      .appendingPathComponent(fileSubPath)
                      .appendingPathComponent(fileName)
        }
    }
}
