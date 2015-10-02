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

    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView! {
        didSet { downloadIndicator.hidden = true }
    }

    var artworkImage: UIImage?

    var song: Song! {
        didSet {
            Alamofire.request(.GET, song.imageURL).responseImage { [weak self] response in
                switch response.result {
                case .Success(let value):
                    if let _self = self {
                        _self.artworkImage = value
                        _self.artworkImageView.image = value
                        _self.artworkImageView.layer.cornerRadius = _self.artworkImageView.frame.size.width / 2
                        _self.artworkImageView.clipsToBounds = true
                        if _self.artworkImageView.hidden {
                            _self.button.hidden = true
                            _self.artworkImageView.hidden = false
                        }
                    }
                case .Failure(let _):
                   return
                }
            }
            /*
            Alamofire.request(.GET, song.imageURL).responseImage { [weak self] (_, _, result) in
                guard let image = result.value else {
                    return
                }
                if let s = self {
                    s.artworkImage = image
                    s.artworkImageView.image = image
                    s.artworkImageView.layer.cornerRadius = s.artworkImageView.frame.size.width / 2
                    s.artworkImageView.clipsToBounds = true
                    if s.artworkImageView.hidden {
                        s.button.hidden = true
                        s.artworkImageView.hidden = false
                    }
                }
            }
            */
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
