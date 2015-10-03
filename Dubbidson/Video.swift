//
//  Video.swift
//  Dubski
//
//  Created by matsuosh on 2015/08/17.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import RealmSwift

final class Video: Object {

    dynamic var id = ""
    dynamic var name = ""
    dynamic var artist = ""
    dynamic var artworkImageURL = ""
    dynamic var createdAt = NSDate()

    var fileURL: NSURL? {
        return FileIO.sharedInstance.videoFileURL(self)
    }

    var thumbnailURL: NSURL? {
        return FileIO.sharedInstance.thumbnailURL(self)
    }

    override class func primaryKey() -> String {
        return "id"
    }

}

extension Video {

    class func all() -> [Video] {
        let results = try! Realm().objects(Video).sorted("createdAt", ascending: false)
        var videos = [Video]()
        for video in results {
            videos.append(video)
        }
        return videos
    }

    class func create(id: String, song: Song) -> Video {
        let video = Video()
        video.id = id
        video.name = song.name
        video.artist = song.artist
        video.artworkImageURL = song.imageURL.absoluteString
        let realm = try! Realm()
        realm.write {
            realm.add(video)
        }

        return video
    }

    class func destroy(videos: [Video]) {
        let realm = try! Realm()
        realm.write {
            for video in videos {
                if let fileURL = video.fileURL {
                    FileIO.sharedInstance.delete(fileURL)
                }
                if let fileURL = video.thumbnailURL {
                    FileIO.sharedInstance.delete(fileURL)
                }
                realm.delete(video)
            }
        }
    }
}