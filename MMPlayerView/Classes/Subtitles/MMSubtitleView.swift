//
//  SubtitleView.swift
//  MMPlayerView
//
//  Created by Millman on 2019/12/19.
//

import UIKit

class MMSubtitleView: UIView {
    var srtTextInput: UIStackView?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    init() {
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear
    }
    
    func update(infos: [SRTInfo], setting: MMSubtitleSetting) {
        if infos.count == 0 {
            srtTextInput?.removeFromSuperview()
            srtTextInput = nil
            return
        }
        
        let lab = infos.map { (data) -> UILabel in
            let label = UILabel()
            label.text = data.text
            label.textColor = .white
            label.textAlignment = .center
            label.numberOfLines = 0
            label.textColor = setting.defaultTextColor
            label.font = setting.defaultFont
            label.backgroundColor = setting.defaultTextBackground
            return label
        }
        
        srtTextInput?.removeFromSuperview()
        srtTextInput = UIStackView.init(arrangedSubviews: lab)
        srtTextInput?.axis = .vertical
        srtTextInput?.distribution = .fillProportionally
        self.addSubview(srtTextInput!)
        let edge = setting.defaultLabelEdge
        
        srtTextInput?.mmLayout
                     .setTop(anchor: self.topAnchor, type: .greaterThanOrEqual(constant: 0))
                     .setLeft(anchor: self.leftAnchor, type: .equal(constant: edge.left))
                     .setRight(anchor: self.rightAnchor, type: .equal(constant: -edge.right))
                     .setBottom(anchor: self.bottomAnchor, type: .equal(constant: -edge.bottom))
    }

}
