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

    func downloadURL(song: Song) -> NSURL? {
        return fileURL(.Temporary, filename: song.previewURL.lastPathComponent)
    }

    func createRecordingFile() -> NSURL? {
        let filename = String(format: "%@.\(Extension.Video.rawValue)", arguments:[formattedTimestamp])
        return fileURL(.Temporary, filename: filename)
    }

    func createVideoFile() -> NSURL? {
        let filename = String(format: "%@.\(Extension.Video.rawValue)", arguments: [formattedTimestamp])
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

    var formattedTimestamp: String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.stringFromDate(NSDate())
    }
    
    func save(image: UIImage, fileURL: NSURL) -> Promise<Bool> {
        return Promise { (fulfill, reject) in
            if UIImagePNGRepresentation(image).writeToFile(fileURL.path!, atomically: true) {
                fulfill(true)
            } else {
                reject(Error.unknown())
            }
        }
    }

}

/*
カメラロールに保存する場合はこれらのメソッドを呼ぶ。

*/

import AssetsLibrary
import Photos

extension FileIO {

    func fetchLastVideoFromPhotos(handler: (Result<AVAsset, NSError>) -> ()) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let videos = PHAsset.fetchAssetsWithMediaType(.Video, options: options)
        if let asset = videos.lastObject as? PHAsset {
            let options = PHVideoRequestOptions()
            options.version = .Original
            PHImageManager.defaultManager().requestAVAssetForVideo(asset, options: options, resultHandler: { (asset, audioMix, info) -> Void in
                if let asset = asset {
                    handler(.Success(Box(asset)))
                } else {
                    handler(.Failure(Box(Error.unknown())))
                }
            })
        }
    }

    func fetchLastVideoFromPhots() -> PHAsset? {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let videos = PHAsset.fetchAssetsWithMediaType(.Video, options: options)
        if let asset = videos.lastObject as? PHAsset {
            return asset
        } else {
            return nil
        }
    }

    func saveVideoToPhotos(fileURL: NSURL, handler: (Result<NSURL, NSError>) -> Void) {
        let library = ALAssetsLibrary()
        library.writeVideoAtPathToSavedPhotosAlbum(fileURL, completionBlock: { (assetURL, error) -> Void in
            if let error = error {
                handler(.Failure(Box(error)))
            }
            if let assetURL = assetURL {
                handler(.Success(Box(assetURL)))
            }
        })
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