//
//  MMPlayerDownloader.swift
//  Pods
//
//  Created by Millman YANG on 2017/9/2.
//
//

import UIKit
import AVFoundation
typealias DownloaderPath = (fullPath: URL, subPath: String)
private let videoExpireInterval = TimeInterval(60*60*12)
public class MMPlayerDownloader: NSObject {
    
    public static let shared: MMPlayerDownloader = {
        NSTemporaryDirectory()
        let shared =  MMPlayerDownloader.init(subPath: "MMPlayerVideo/Share")
        return shared
    }()
    fileprivate var downloadBLock = [URL: ((MMPlayerDownloadStatus) -> Void)]()
    fileprivate var mapList = [URL: MMPlayerDownloadRequest]()
    fileprivate var plistPath: URL {
        return self.downloadPathInfo.fullPath.appendingPathComponent("Video")
    }

    let downloadPathInfo: DownloaderPath

    fileprivate var _downloadInfo = [MMPlayerDownLoadVideoInfo]()
    public private(set) var downloadInfo: [MMPlayerDownLoadVideoInfo] {
        set {
            let data = try? JSONEncoder().encode(newValue)
            try? data?.write(to: plistPath, options: .atomic)
            self._downloadInfo = newValue
        } get {
            return self._downloadInfo
        }
    }
    
    public init(subPath sub: String) {
        self.downloadPathInfo = (URL.init(fileURLWithPath: VideoBasePath).appendingPathComponent(sub), sub)
        super.init()
        self.create(path: self.downloadPathInfo.fullPath.path)
        self.createPlist(path: plistPath.path)
        if let info = try? Data.init(contentsOf: plistPath) {
            self._downloadInfo = info.decodeObject() ?? [MMPlayerDownLoadVideoInfo]()
        }
    }
    
//    public func deletedExpireVideo() {
//        if let allVideos = FileManager.default.subpaths(atPath: self.downloaderPath.fullPath.path){
//            allVideos.forEach({ (path) in
//                let absolutePath = downloadPath.appendingPathComponent(path)
//                if let attribute = try? FileManager.default.attributesOfItem(atPath: absolutePath.path),
//                   let createDate = attribute[.creationDate] as? Date,
//                   Date() >= createDate.addingTimeInterval(videoExpireInterval){
//                    try? FileManager.default.removeItem(at: absolutePath)
//                }
//            })
//        }
//    }
//    
//    public func deleteAllVideo() {
//        do {
//            try? FileManager.default.removeItem(at: downloadPath)
//        } catch let error {
//            print(error.localizedDescription)
//        }
//        self.create(path: downloadPath.path)
//    }
    
    public func localFileFrom(url: URL) -> MMPlayerDownLoadVideoInfo? {
        return downloadInfo.first { (info) -> Bool in
            return info.url == url
        }
    }
    
    public func observe(downloadURL: URL, status: ((_ status: MMPlayerDownloadStatus) -> Void)?) {
        downloadBLock[downloadURL] = status
        if self.localFileFrom(url: downloadURL) != nil {
            self.downloadBLock[downloadURL]?(.exist)
        }
    }
    
    public func download(url: URL, fileName: String? = nil) {
        if url.isFileURL {
            fatalError("Input fileURL is Invalid \(url.absoluteString)")
        }
        
        if mapList[url] != nil {
            return
        }
        
        self.downloadInfo.removeAll { $0.url == url }
        let name = fileName ?? url.lastPathComponent
        let asset = AVURLAsset(url: url)
        mapList[url] = MMPlayerDownloadRequest(asset: asset,
                                               pathInfo: downloadPathInfo,
                                               fileName: name)
        mapList[url]?.start(status: { [weak self] in
            self?.downloadBLock[url]?($0)
            switch $0 {
            case .completed(let info):
                self?.downloadInfo.append(info)
                self?.downloadBLock[url] = nil
                self?.mapList[url] = nil
            case  .cancelled , .failed:
                self?.mapList[url] = nil
                self?.downloadBLock[url] = nil
            default:
                break
            }
        })
    }
    
    fileprivate func create(path: String) {
        let manager = FileManager.default
        var dir: ObjCBool = false
        if !manager.fileExists(atPath: path, isDirectory: &dir) {
            do {
                try manager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                
            } catch {
                print("Error create Dire")
            }
        }
    }
    
    fileprivate func createPlist(path: String) {
        let manager = FileManager.default
        var dir: ObjCBool = false
        if !manager.fileExists(atPath: path, isDirectory: &dir) {
            manager.createFile(atPath: path, contents: nil, attributes: nil)
        }
    }
    fileprivate func writeVideoInfo(data: Data? = nil, url: URL) {
        try? data?.write(to: url, options: .atomic)
    }
}

