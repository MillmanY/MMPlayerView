//
//  MMSubtitleSetting.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/18.
//

import UIKit
public protocol MMSubtitleSettingProtocol: class {
    func setting(_ mmsubtitleSetting: MMSubtitleSetting, fontChange: UIFont)
    func setting(_ mmsubtitleSetting: MMSubtitleSetting, textColorChange: UIColor)
    func setting(_ mmsubtitleSetting: MMSubtitleSetting, labelEdgeChange: (bottom: CGFloat, left: CGFloat, right: CGFloat))
    func setting(_ mmsubtitleSetting: MMSubtitleSetting, typeChange: MMSubtitleSetting.SubtitleType?)
}

extension MMSubtitleSetting {
    public enum SubtitleType {
        case srt(info: String)
    }
}

public class MMSubtitleSetting: NSObject {
    weak var delegate: MMSubtitleSettingProtocol?
    public init(delegate: MMSubtitleSettingProtocol) {
        self.delegate = delegate
    }
    
    var subtitleObj: AnyObject?
    public var defaultFont: UIFont = UIFont.systemFont(ofSize: 17) {
        didSet {
            self.delegate?.setting(self, fontChange: defaultFont)
        }
    }
    public var defaultTextColor: UIColor = UIColor.white {
        didSet {
            self.delegate?.setting(self, textColorChange: defaultTextColor)
        }
    }
    
    public var defaultTextBackground: UIColor = UIColor.clear {
        didSet {
        }
    }
    
    public var defaultLabelEdge: (bottom: CGFloat, left: CGFloat, right: CGFloat) = (20,10,10) {
        didSet {
            self.delegate?.setting(self, labelEdgeChange: defaultLabelEdge)
        }
    }
    public var subtitleType: SubtitleType? {
        didSet {
            guard let type = self.subtitleType else {
                subtitleObj = nil
                subtitleType = nil
                return
            }
            switch type {
            case .srt(let info):
                let obj = SubtitleConverter(SRT())
                obj.parseText(info)
                subtitleObj = obj
            }
            self.delegate?.setting(self, typeChange: subtitleType)
        }
    }
}
