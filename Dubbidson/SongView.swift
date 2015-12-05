//
//  SongView.swift
//  Dubski
//
//  Created by matsuosh on 2015/08/16.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

class SongView: UIView {
    @IBOutlet weak var artworkView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    var song: Song? {
        didSet {
            hidden = false
        }
    }
    func configure(song: Song) {
        self.song = song
        artworkView.af_setImageWithURL(song.artworkURL)
        nameLabel.text = song.name
        artistLabel.text = song.artist
    }
}
