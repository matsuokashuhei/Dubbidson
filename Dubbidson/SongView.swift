//
//  SongView.swift
//  Dubski
//
//  Created by matsuosh on 2015/08/16.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

import Kingfisher

protocol SongViewDelegate {
    func songViewTapped()
}

class SongView: UIView {

    @IBOutlet weak var button: UIButton! {
        didSet { button.addTarget(self, action: "buttonTapped", forControlEvents: .TouchUpInside) }
    }

    @IBOutlet weak var artworkImageView: UIImageView! {
        didSet {
            artworkImageView.userInteractionEnabled = true
            artworkImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "artworkImageViewTapped:"))
            artworkImageView.hidden = true
        }
    }

    var artworkImage: UIImage?

    var song: Song! {
        didSet {
            artworkImageView.kf_setImageWithURL(song.imageURL)
            artworkImageView.layer.cornerRadius = artworkImageView.frame.size.width / 2
            artworkImageView.clipsToBounds = true
            if artworkImageView.hidden {
                button.hidden = true
                artworkImageView.hidden = false
            }
            let downloader = KingfisherManager.sharedManager.downloader
            downloader.downloadImageWithURL(song.imageURL, progressBlock: nil) { (image, error, imageURL) -> () in
                if let image = image {
                    self.artworkImage = image
                }
            }
        }
    }

    var delegate: SongViewDelegate?

    func buttonTapped() {
        delegate?.songViewTapped()
    }

    func artworkImageViewTapped(sender: UITapGestureRecognizer) {
        delegate?.songViewTapped()
    }


}
