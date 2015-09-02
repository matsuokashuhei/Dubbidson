//
//  TemporaryFile.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/27.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import RealmSwift
import XCGLogger

enum MediaType: String {
    case Audio = "Audio"
    case Video = "Video"
}

class AudioFile: Object {

    dynamic var name = ""
    dynamic var createdAt = NSDate()

    override class func primaryKey() -> String {
        return "name"
    }

}

extension AudioFile {

    class func all() -> [AudioFile] {
        let results = Realm().objects(AudioFile).sorted("createdAt")
        var files = [AudioFile]()
        for file in results {
            files.append(file)
        }
        return files
    }

    class func exists(fileURL: NSURL) -> Bool {
        if let fileName = fileURL.lastPathComponent {
            if let result = Realm().objectForPrimaryKey(AudioFile.self, key: fileName) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

    class func create(fileURL: NSURL) {
        if let fileName = fileURL.lastPathComponent {
            let file = AudioFile()
            file.name = fileName
            let realm = Realm()
            realm.write {
                realm.add(file)
                let files = self.all()
                XCGLogger.defaultInstance().verbose("files.count: \(files.count)")
                if files.count > 5 {
                    if let file = files.first {
                        XCGLogger.defaultInstance().verbose("realm.delete(file)")
                        realm.delete(file)
                    }
                }
            }
        }
    }
}