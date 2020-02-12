//
//  PlayerCell.swift
//  MMPlayerView
//
//  Created by Millman YANG on 2017/8/23.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit

class PlayerCell: UICollectionViewCell {
    var data:DataObj? {
        didSet {
            self.imgView.image = data?.image
            self.labTitle.text = data?.title
        }
    }
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var labTitle: UILabel!
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgView.isHidden = false
        data = nil
    }
}
