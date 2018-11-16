//
//  MMPlayerHLSDownloader.swift
//  MMPlayerView
//
//  Created by Millman on 2018/11/16.
//

import UIKit
import AVFoundation

extension MMPlayerHLSManager {
    public enum Status {
        case none
        case downloading(value: Float)
        case completed(data: Data)
        case failed(err: String)
    }

}

class MMPlayerHLSManager: NSObject {
    static let shared = MMPlayerHLSManager()

    fileprivate var willDownloadToUrlMap = [AVAggregateAssetDownloadTask: URL]()
    fileprivate var taskMap = [AVAggregateAssetDownloadTask: (Status)->Void]()

    lazy var downloadSession: AVAssetDownloadURLSession = {
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "Download-Identifier")
        return AVAssetDownloadURLSession.init(configuration: backgroundConfiguration, assetDownloadDelegate: self, delegateQueue: OperationQueue.main)
    }()
    
    func start(asset: AVURLAsset,fileName: String, status:((_ status: Status)->Void)?) {
        let preferredMediaSelection = asset.preferredMediaSelection
        guard let task = downloadSession.aggregateAssetDownloadTask(with: asset,
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
        status?(.none)
    }
}

extension MMPlayerHLSManager: AVAssetDownloadDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
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
                self.taskMap[task]?(.completed(data: data))
            } catch let dataErr {
                self.taskMap[task]?(.failed(err: dataErr.localizedDescription))
            }
            self.taskMap[task] = nil
        }
    }
    
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
