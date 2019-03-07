//
//  MMPlayerDownloadManager
//  MMPlayerView
//
//  Created by Millman on 2018/11/16.
//

import UIKit
import AVFoundation

extension MMPlayerDownloadManager {
    public enum Status {
        case none
        case downloading(value: Float)
        case completed(data: Data, type: VideoType)
        case failed(err: String)
    }
}

class MMPlayerDownloadManager: NSObject {
    static let shared = MMPlayerDownloadManager(identifier: "Shared-Identifier")
    private var hlsSession: AVAssetDownloadURLSession!
    private var fileSession: URLSession!

    init(identifier: String) {
        let config: URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: identifier)
        super.init()
        self.hlsSession = AVAssetDownloadURLSession(configuration: config, assetDownloadDelegate: self, delegateQueue: OperationQueue.main)
        self.fileSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
    }

    fileprivate var willDownloadToUrlMap = [AVAggregateAssetDownloadTask: URL]()
    fileprivate var taskMap = [URLSessionTask: (Status)->Void]()
    
    func start(asset: AVURLAsset,fileName: String, status:((_ status: Status)->Void)?) {
        if asset.url.lastPathComponent.contains("m3u8") {
            let preferredMediaSelection = asset.preferredMediaSelection
            guard let task = hlsSession.aggregateAssetDownloadTask(with: asset,
                                                                        mediaSelections: [preferredMediaSelection],
                                                                        assetTitle: fileName,
                                                                        assetArtworkData: nil,
                                                                        options:
                [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 265_000]) else {
                    status?(.failed(err: "Task Init error"))
                    return
            }
            task.resume()
            self.taskMap[task] = status
        } else {
            let task = fileSession.downloadTask(with: asset.url)
            task.resume()
            self.taskMap[task] = status
        }
    }
}

extension MMPlayerDownloadManager: AVAssetDownloadDelegate, URLSessionDownloadDelegate {
    // normal file
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            self.taskMap[downloadTask]?(.completed(data: data, type: .mp4))
            try? FileManager.default.removeItem(at: location)
        } catch let dataErr {
            self.taskMap[downloadTask]?(.failed(err: dataErr.localizedDescription))
        }
        self.taskMap[downloadTask] = nil
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percentComplete = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        self.taskMap[downloadTask]?(.downloading(value: percentComplete))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if session == fileSession {
            self.fileError(session: session, task: task, didCompleteWithError: error)
        } else if session == hlsSession {
            self.aggregateError(session: session, task: task, didCompleteWithError: error)
        }
    }
    // hls file
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask,
                    willDownloadTo location: URL) {
        willDownloadToUrlMap[aggregateAssetDownloadTask] = location
    }
    
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask,
                    didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue],
                    timeRangeExpectedToLoad: CMTimeRange, for mediaSelection: AVMediaSelection) {
        
        let percentComplete = loadedTimeRanges.reduce(0) { (rc, value) -> Float in
            let loadedTimeRange: CMTimeRange = value.timeRangeValue
            return rc + Float((loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds))
        }
        self.taskMap[aggregateAssetDownloadTask]?(.downloading(value: percentComplete))
    }
}

extension MMPlayerDownloadManager {
    private func aggregateError(session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let task = task as? AVAggregateAssetDownloadTask else { return }
        if let err = error as NSError? {
            switch (err.domain, err.code) {
            case (NSURLErrorDomain, NSURLErrorUnknown):
                fatalError("Downloading HLS streams is not supported in the simulator.")
            default:
                self.taskMap[task]?(.failed(err: err.localizedDescription))
            }
        } else if willDownloadToUrlMap[task] == nil {
            task.resume()
        } else {
            guard let downloadURL = willDownloadToUrlMap.removeValue(forKey: task) else { return }
            do {
                let data = try downloadURL.bookmarkData()
                
                self.taskMap[task]?(.completed(data: data, type: .hls))
            } catch let dataErr {
                self.taskMap[task]?(.failed(err: dataErr.localizedDescription))
            }
            self.taskMap[task] = nil
        }
    }
    
    private func fileError(session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let err = error?.localizedDescription {
            self.taskMap[task]?(.failed(err: err))
        }
        self.taskMap[task] = nil
    }

}
