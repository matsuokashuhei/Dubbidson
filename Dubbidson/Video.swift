//
//  Video.swift
//  Dubski
//
//  Created by matsuosh on 2015/08/17.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import RealmSwift

class Video: Object {
    dynamic var name = ""
    dynamic var artist = ""
    dynamic var artworkImageURL = ""
    dynamic var fileURL = ""
    dynamic var createdAt = NSDate()
}

extension Video {

    class func all() -> [Video] {
        let results = Realm().objects(Video)
        var videos = [Video]()
        for video in results {
            videos.append(video)
        }
        return videos
    }

    class func create(song: Song, fileURL: NSURL) -> () {
        let video = Video()
        video.name = song.name
        video.artist = song.artist
        video.artworkImageURL = song.imageURL.absoluteString!
        video.fileURL = fileURL.absoluteString!
        let realm = Realm()
        realm.write {
            realm.add(video)
        }
    }

}