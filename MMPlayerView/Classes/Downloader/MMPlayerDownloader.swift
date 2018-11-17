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
@available(iOS 11.0, *)
extension MMPlayerDownloader {
    public enum DownloadStatus {
        case none
        case downloading(value: Float)
        case completed(info: MMPlayerDownLoadVideoInfo)
        case failed(err: String)
        case cancelled
        case exist
    }
}

@available(iOS 11.0, *)
public class MMPlayerDownloader: NSObject {
    
    let downloadObserverManager = MMPlayerMapObserverManager<URL,((DownloadStatus) -> Void)>()

    fileprivate let hls: MMPlayerHLSManager
    public static let shared: MMPlayerDownloader = {
        let shared =  MMPlayerDownloader.init(subPath: "MMPlayerVideo/Share")
        return shared
    }()
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
        self.hls = MMPlayerHLSManager(identifier: sub)
        super.init()
        self.create(path: self.downloadPathInfo.fullPath.path)
        self.createPlist(path: plistPath.path)
        if let info = try? Data.init(contentsOf: plistPath) {
            self._downloadInfo = info.decodeObject() ?? [MMPlayerDownLoadVideoInfo]()
        }
    }
    
    public func deleteVideo(_ videoInfo: MMPlayerDownLoadVideoInfo) {
        downloadInfo.removeAll { (info) -> Bool in
            if info == videoInfo {
                try? FileManager.default.removeItem(at: info.localURL)
                self.downloadObserverManager[info.url].forEach({ $0(.none) })
                return true
            }
            return false
        }
    }
    
    public func localFileFrom(url: URL) -> MMPlayerDownLoadVideoInfo? {
        return downloadInfo.first { (info) -> Bool in
            return info.url == url
        }
    }
    
    public func observe(downloadURL: URL, status: @escaping ((_ status: MMPlayerDownloader.DownloadStatus) -> Void)) -> MMPlayerObservation {
        let value = self.downloadObserverManager.add(key: downloadURL, observer: status)
        if self.localFileFrom(url: downloadURL) != nil {
            self.downloadObserverManager[downloadURL].forEach({ $0(.exist) })
        }
        return value
    }
    
    public func download(url: URL, fileName: String? = nil) {
        if url.isFileURL {
            fatalError("Input fileURL are Invalid \(url.absoluteString)")
        }
        
        if mapList[url] != nil { return }
        
        self.downloadInfo.removeAll { $0.url == url }
        let name = fileName ?? url.absoluteString.base64
        let asset = AVURLAsset(url: url)
        
        mapList[url] = MMPlayerDownloadRequest(asset: asset,
                                               pathInfo: downloadPathInfo,
                                               fileName: name,
                                               manager: hls)
        
        mapList[url]?.start(status: { [weak self] in
            let status = $0
            self?.downloadObserverManager[url].forEach({ $0(status) })
            switch status {
            case .completed(let info):
                self?.downloadInfo.append(info)
                self?.mapList[url] = nil
            case  .cancelled , .failed:
                self?.mapList[url] = nil
                self?.downloadObserverManager.remove(key: url)
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

