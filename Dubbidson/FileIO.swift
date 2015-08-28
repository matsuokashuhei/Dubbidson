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

    enum Extension: String {
        case Video = "mp4"
        case Image = "png"
    }

    static let sharedInstance = FileIO()

    func isVideoFile(fileName: String) -> Bool {
        return fileName.pathExtension == Extension.Video.rawValue
    }

    func isVideoURL(URL: NSURL) -> Bool {
        return URL.lastPathComponent?.pathExtension == Extension.Video.rawValue
        /*
        if let pathExtension = URL.lastPathComponent?.pathExtension {
            return pathExtension == "m4v"
        }
        return false
        */
    }

    func audioFileURL(song: Song) -> NSURL? {
        return fileURL(.Temporary, filename: song.previewURL.lastPathComponent)
    }

    func audioFileURL(song: Song) -> Promise<NSURL> {
        return Promise { (filfull, reject) in
            if let URL = audioFileURL(song) {
                filfull(URL)
            } else {
                reject(NSError())
            }
        }
    }

    func recordingFileURL() -> NSURL? {
        let filename = String(format: "%@.\(Extension.Video.rawValue)", arguments:[timestamp()])
        return fileURL(.Temporary, filename: filename)
    }

    func videoFileURL() -> NSURL? {
        let filename = String(format: "%@.\(Extension.Video.rawValue)", arguments: [timestamp()])
        return fileURL(.Documents, filename: filename)
    }

    func videoFileURL(video: Video) -> NSURL? {
        if let directory = Directory.Documents.URL, let destinationURL = NSURL(string: "\(video.id).\(Extension.Video.rawValue)", relativeToURL: directory) {
            return destinationURL
        } else {
            return nil
        }
    }

    func thumbnailURL(video: Video) -> NSURL? {
        if let directory = Directory.Documents.URL, let destinationURL = NSURL(string: "\(video.id).\(Extension.Image.rawValue)", relativeToURL: directory) {
            return destinationURL
        } else {
            return nil
        }
    }

    func fileURL(directory: Directory, filename: String?) -> NSURL? {
        if let directory = directory.URL, let filename = filename, let destinationURL = NSURL(string: filename, relativeToURL: directory) {
            return destinationURL
        } else {
            return nil
        }
    }

    func delete(fileURL: NSURL) -> Result<Bool, NSError> {
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

    func timestamp(format: String = "yyyyMMddHHmmss") -> String {
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