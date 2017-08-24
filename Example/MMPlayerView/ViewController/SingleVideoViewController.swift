//
//  SingleVideoViewController.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2017/8/22.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation
import MMPlayerView
class SingleVideoViewController: UIViewController {
    @IBOutlet weak var playView: MMPlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL.init(string: "http://www.html5videoplayer.net/videos/toystory.mp4")!
        playView.replace(cover: CoverA.instantiateFromNib())
        playView.set(url: url, thumbImage: #imageLiteral(resourceName: "seven")) { (status) in
            switch status {
            case .ready:
                print("Ready to play")
            case .failed(let err):
                print("Failed \(err.description)")
            case .pause:
                print("Pause")
            case .playing:
                print("playing")
            case .end:
                print("End")
            case .unknown:
                print("unknown")
            }
        }
    }
}
