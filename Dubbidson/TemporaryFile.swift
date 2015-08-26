//
//  TemporaryFile.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/27.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import RealmSwift

enum MediaType: String {
    case Audio = "Audio"
    case Video = "Video"
}

class TemporaryFile: Object {

    dynamic var name = ""
    dynamic var mediaType = ""
    dynamic var createdAt = NSDate()

    override class func primaryKey() -> String {
        return "name"
    }

}

extension TemporaryFile {

    class func videoFiles() -> [TemporaryFile] {
        return temporaryFiles(.Video)
    }

    class func audioFiles() -> [TemporaryFile] {
        return temporaryFiles(.Audio)
    }

    class func temporaryFiles(type: MediaType) -> [TemporaryFile] {
        let results = Realm().objects(TemporaryFile).filter("mediaType = '\(type.rawValue)'").sorted("createdAt")
        var files = [TemporaryFile]()
        for file in results {
            files.append(file)
        }
        return files
    }

    class func exists(fileURL: NSURL) -> Bool {
        if let fileName = fileURL.lastPathComponent {
            let results = Realm().objects(TemporaryFile).filter("name = '\(fileName)'")
            return results.count > 0
        } else {
            return false
        }
    }

    class func create(fileURL: NSURL) {
        if let fileName = fileURL.lastPathComponent {
            let file = TemporaryFile()
            file.name = fileName
            if fileName.pathExtension == "m4v" {
                file.mediaType = MediaType.Video.rawValue
            } else {
                file.mediaType = MediaType.Audio.rawValue
            }
            let realm = Realm()
            realm.write {
                realm.add(file)
            }
        }
    }
}