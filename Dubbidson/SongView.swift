//
//  SongView.swift
//  Dubski
//
//  Created by matsuosh on 2015/08/16.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

import Alamofire
import AlamofireImage
import PromiseKit

protocol SongViewDelegate {
    func songViewTapped()
    func readyToPlay(song: Song)
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

    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView! {
        didSet { downloadIndicator.hidden = true }
    }

    var artworkImage: UIImage?

    var song: Song! {
        didSet {
            getArtworkImage(song.artworkURL)
            if AudioFile.exists(song.previewURL) {
                delegate?.readyToPlay(song)
            } else {
                downloadSong(song)
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

    private func getArtworkImage(imageURL: NSURL) {
        Alamofire.request(.GET, imageURL).responseImage { [weak self] response in
            switch response.result {
            case .Success(let value):
                guard let _self = self else {
                    return
                }
                _self.artworkImage = value
                _self.artworkImageView.image = value
                _self.artworkImageView.layer.cornerRadius = _self.artworkImageView.frame.size.width / 2
                _self.artworkImageView.clipsToBounds = true
                if _self.artworkImageView.hidden {
                    _self.button.hidden = true
                    _self.artworkImageView.hidden = false
                }
            case .Failure(_):
               return
            }
        }
    }

    private func downloadSong(song: Song) {
        downloadIndicator.hidden = false
        downloadIndicator.startAnimating()
        Downloader.sharedInstance.download(song).then { [weak self] audioURL -> () in
            AudioFile.create(audioURL)
            self?.delegate?.readyToPlay(song)
        }.finally {
            self.downloadIndicator.stopAnimating()
            self.downloadIndicator.hidden = true
        }.catch_ { error in
            Notificator.sharedInstance.showError(error)
        }
    }
}
