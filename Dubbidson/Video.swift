//
//  Movie.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/11/24.
//  Copyright © 2015年 matsuosh. All rights reserved.
//

import RealmSwift
import XCGLogger

class Video: Object {

    dynamic var id = ""
    dynamic var fileName = ""
    dynamic var thumbnailData: NSData? = nil
    dynamic var song: Song? = nil
    dynamic var created = NSDate()

    override internal var description: String {
        return "id: \(id), song: \(song), created: \(created)"
    }


    var fileURL: NSURL? {
        if #available(iOS 9.0, *) {
            return NSURL(fileURLWithPath: "\(id).mp4", isDirectory: false, relativeToURL: Directory.Documents.URL)
        } else {
            return NSURL(string: "\(id).mp4", relativeToURL: Directory.Documents.URL)
        }
    }

    var thumbnail: UIImage {
        return UIImage(data: thumbnailData!)!
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    func save() {
        id = fileName.stringByReplacingOccurrencesOfString(".mp4", withString: "")
        XCGLogger.defaultInstance().verbose("video: \(self)")
        DB.sharedInstance.save(self)
    }

    func delete() {
        if let fileURL = fileURL where NSFileManager.defaultManager().fileExistsAtPath(fileURL.absoluteString) {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(fileURL)
            } catch let error as NSError {
                XCGLogger.defaultInstance().error(error.description)
            }
        }
        DB.sharedInstance.delete(self)
    }

}

extension Video {

    class func all() -> [Video] {
        XCGLogger.defaultInstance().verbose("")
        do {
            let realm = try Realm()
            return realm.objects(Video).sorted("created", ascending: false).map { video in video }
        } catch let error as NSError {
            XCGLogger.defaultInstance().error(error.description)
            return []
        }
    }

}
