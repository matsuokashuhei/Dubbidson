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

    dynamic var id = ""
    dynamic var name = ""
    dynamic var artist = ""
    dynamic var artworkImageURL = ""
    dynamic var createdAt = NSDate()

    override class func primaryKey() -> String {
        return "id"
    }

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

    //class func create(song: Song, videoURL: NSURL, thumbnailURL: NSURL) -> Video {
    class func create(id: String, song: Song) -> Video {
        let video = Video()
        video.id = id
        video.name = song.name
        video.artist = song.artist
        video.artworkImageURL = song.imageURL.absoluteString!
        //video.fileURL = fileURL.absoluteString!
        //video.fileName = fileURL.lastPathComponent!
        let realm = Realm()
        realm.write {
            realm.add(video)
        }
        return video
    }

}