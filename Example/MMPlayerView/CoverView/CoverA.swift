//
//  CoverA.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2017/8/22.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import MMPlayerView
import AVFoundation

class CoverA: UIView, MMPlayerCoverViewProtocol {
    weak var playLayer: MMPlayerLayer?
    fileprivate var isUpdateTime = false

    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var playSlider: UISlider!
    @IBOutlet weak var labTotal: UILabel!
    @IBOutlet weak var labCurrent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnPlay.imageView?.tintColor = UIColor.white
    }
    @IBAction func btnAction() {
        self.playLayer?.delayHideCover()
        if playLayer?.player?.rate == 0{
            self.playLayer?.player?.play()
        } else {
            self.playLayer?.player?.pause()
        }
    }
    
    func currentPlayer(status: MMPlayerPlayStatus) {
        switch status {
        case .playing:
            self.btnPlay.setImage(#imageLiteral(resourceName: "ic_pause_circle_filled"), for: .normal)
        default:
            self.btnPlay.setImage(#imageLiteral(resourceName: "ic_play_circle_filled"), for: .normal)
        }
    }
    
    func timerObserver(time: CMTime) {
        if let duration = self.playLayer?.player?.currentItem?.asset.duration ,
            !duration.isIndefinite ,
            !isUpdateTime {
            if self.playSlider.maximumValue != Float(duration.seconds) {
                self.playSlider.maximumValue = Float(duration.seconds)
            }
            self.labCurrent.text = self.convert(second: time.seconds)
            self.labTotal.text = self.convert(second: duration.seconds-time.seconds)
            self.playSlider.value = Float(time.seconds)
        }
    }

    fileprivate func convert(second: Double) -> String {
        let component =  Date.dateComponentFrom(second: second)
        if let hour = component.hour ,
            let min = component.minute ,
            let sec = component.second {
            
            let fix =  hour > 0 ? NSString(format: "%02d:", hour) : ""
            return NSString(format: "%@%02d:%02d", fix,min,sec) as String
        } else {
            return "-:-"
        }
    }
    
    @IBAction func sliderValueChange(slider: UISlider) {
        self.isUpdateTime = true
        self.playLayer?.delayHideCover()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(delaySeekTime), object: nil)
        self.perform(#selector(delaySeekTime), with: nil, afterDelay: 0.1)
    }
    
    func delaySeekTime() {
        let time =  CMTimeMake(Int64(self.playSlider.value), 1)
        self.playLayer?.player?.seek(to: time, completionHandler: { [unowned self] (finish) in
            self.isUpdateTime = false
        })
    }
    
    func player(isMuted: Bool) {
        
    }

    func removeObserver() {
        
    }
    
    func addObserver() {
        
    }
}

extension Date {
    static func dateComponentFrom(second: Double) -> DateComponents {
        let interval = TimeInterval(second)
        let date1 = Date()
        let date2 = Date(timeInterval: interval, since: date1)
        let c = NSCalendar.current
        
        var components = c.dateComponents([.year,.month,.day,.hour,.minute,.second,.weekday], from: date1, to: date2)
        components.calendar = c
        return components
    }
}
