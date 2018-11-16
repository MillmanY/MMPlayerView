//
//  MMPlayerDownLoadVideoInfo.swift
//  MMPlayerView
//
//  Created by Millman on 2018/11/15.
//

import Foundation

public struct MMPlayerDownLoadVideoInfo: Codable, Equatable {
    public enum VideoType: Int, Codable {
        case mp4 = 0
        case hls
    }

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
    
    public static func == (lhs: MMPlayerDownLoadVideoInfo, rhs: MMPlayerDownLoadVideoInfo) -> Bool {
        return lhs.url == rhs.url &&
               lhs.type == rhs.type &&
               lhs.fileName == rhs.fileName &&
               lhs.fileSubPath == rhs.fileSubPath
    }
}
