//
//  FileManager.swift
//  GPUImageTest
//
//  Created by matsuosh on 2015/07/27.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

class FileManager {

    class func videoFileURL() -> NSURL? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let stringFromDate = formatter.stringFromDate(NSDate())
        //let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        //return directory.URLByAppendingPathComponent("\(stringFromDate).m4v")
        if let directory = Directory.Temporary.URL, let destinationURL = NSURL(string: "\(stringFromDate).m4v", relativeToURL: directory) {
            return destinationURL
        } else {
            return nil
        }
    }

    class func audioFileURL(song: Song) -> NSURL? {
        if let directory = Directory.Temporary.URL, let lastPath = song.previewURL.lastPathComponent, let destinationURL = NSURL(string: lastPath, relativeToURL: directory) {
            return destinationURL
        } else {
            return nil
        }
    }

    class func videoFileURL(video: Video) -> NSURL? {
        if let directory = Directory.Documents.URL, let destinationURL = NSURL(string: video.fileName, relativeToURL: directory) {
            return destinationURL
        } else {
            return nil
        }
    }
}

enum Directory {

    case Documents
    case Caches
    case Temporary

    var URL: NSURL? {
        switch self {
        case .Documents:
            return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as? NSURL
        case .Caches:
            return NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first as? NSURL
        case .Temporary:
            if let path = NSTemporaryDirectory(), let URL = NSURL(fileURLWithPath: path) {
                return URL
            } else {
                return nil
            }
        }
    }

}