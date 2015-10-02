//
//  FileManager.swift
//  GPUImageTest
//
//  Created by matsuosh on 2015/07/27.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation
import UIKit

import PromiseKit
import Result

class FileIO {

    enum Extension: String {
        case Video = "mp4"
        case Image = "png"
        func add(fileName: String) -> String {
            return "\(fileName).\(self.rawValue)"
        }
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
        guard let directory = Directory.Documents.URL else {
            return nil
        }
        guard let destinationURL = NSURL(string: Extension.Video.add(video.id), relativeToURL: directory) else {
            return nil
        }
        return destinationURL
    }

    func thumbnailURL(video: Video) -> NSURL? {
        guard let directory = Directory.Documents.URL else {
            return nil
        }
        guard let destinationURL = NSURL(string: Extension.Image.add(video.id), relativeToURL: directory) else {
            return nil
        }
        return destinationURL
    }

    func fileURL(directory: Directory, filename: String?) -> NSURL? {
        guard let directory = directory.URL else {
            return nil
        }
        guard let filename = filename else {
            return nil
        }
        guard let destinationURL = NSURL(string: filename, relativeToURL: directory) else {
            return nil
        }
        return destinationURL
    }

    func delete(fileURL: NSURL) -> Result<Bool, NSError> {
        guard let path = fileURL.path else {
            return .Failure(NSError.errorWithAppError(.Unknown))
        }
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
                return .Success(true)
            } catch let error as NSError {
                return .Failure(error)
            }
        } else {
            return .Success(false)
        }
        /*
        if let path = fileURL.path {
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(path)
                    return .Success(true)
                } catch let error as NSError {
                    return .Failure(error)
                }
            } else {
                return .Success(false)
            }
        } else {
            return .Success(false)
        }
        */
    }

    var formattedTimestamp: String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.stringFromDate(NSDate())
    }
    
    func save(image: UIImage, fileURL: NSURL) -> Promise<Bool> {
        return Promise { (fulfill, reject) in
            guard let image = UIImagePNGRepresentation(image) else {
                reject(NSError.errorWithAppError(.UIImagePNGRepresentationIsFailed))
                return
            }
            do {
                try image.writeToFile(fileURL.path!, options: .AtomicWrite)
                fulfill(true)
            } catch let error as NSError {
                reject(error)
            }
            /*
            if UIImagePNGRepresentation(image).writeToFile(fileURL.path!, atomically: true) {
                fulfill(true)
            } else {
                reject(Error.unknown())
            }
            */
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
                    handler(.Success(asset))
                } else {
                    handler(.Failure(NSError.errorWithAppError(.Unknown)))
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
        //PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(fileURL)
        // TODO: iOS9から非推奨
        let library = ALAssetsLibrary()
        library.writeVideoAtPathToSavedPhotosAlbum(fileURL, completionBlock: { (assetURL, error) -> Void in
            if let error = error {
                handler(.Failure(error))
            }
            if let assetURL = assetURL {
                handler(.Success(assetURL))
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
            return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        case .Caches:
            return NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first
        case .Temporary:
            return NSURL(fileURLWithPath: NSTemporaryDirectory())
        }
    }

}