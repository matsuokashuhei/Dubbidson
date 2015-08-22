//
//  FileManager.swift
//  GPUImageTest
//
//  Created by matsuosh on 2015/07/27.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation
import UIKit

import Box
import PromiseKit
import Result

class FileIO {

    static let sharedInstace = FileIO()

    class func audioFileURL(song: Song) -> NSURL? {
        return fileURL(.Temporary, filename: song.previewURL.lastPathComponent)
    }

    class func audioFileURL(song: Song) -> Promise<NSURL> {
        return Promise { (filfull, reject) in
            if let URL = audioFileURL(song) {
                filfull(URL)
            } else {
                reject(NSError())
            }
        }
    }

    class func recordingFileURL() -> NSURL? {
        let filename = String(format: "%@.m4v", arguments:[timestamp()]) 
        return fileURL(.Temporary, filename: filename)
    }

    class func videoFileURL() -> NSURL? {
        let filename = String(format: "%@.m4v", arguments: [timestamp()])
        return fileURL(.Documents, filename: filename)
    }

    func videoFileURL(video: Video) -> NSURL? {
        if let directory = Directory.Documents.URL, let destinationURL = NSURL(string: "\(video.id).m4v", relativeToURL: directory) {
            return destinationURL
        } else {
            return nil
        }
    }

    func thumbnailURL(video: Video) -> NSURL? {
        if let directory = Directory.Documents.URL, let destinationURL = NSURL(string: "\(video.id).png", relativeToURL: directory) {
            return destinationURL
        } else {
            return nil
        }
    }

    class func fileURL(directory: Directory, filename: String?) -> NSURL? {
        if let directory = directory.URL, let filename = filename, let destinationURL = NSURL(string: filename, relativeToURL: directory) {
            return destinationURL
        } else {
            return nil
        }
    }

    class func delete(fileURL: NSURL) -> Result<Bool, NSError> {
        if let path = fileURL.path {
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                var error: NSError?
                let result = NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
                if let error = error {
                    return .Failure(Box(error))
                }
                return .Success(Box(result))
            } else {
                return .Success(Box(false))
            }
        } else {
            return .Success(Box(false))
        }
    }

    class func timestamp(format: String = "yyyyMMddHHmmss") -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(NSDate())
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