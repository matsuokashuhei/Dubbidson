//
//  Downloader.swift
//  GPUImageTest
//
//  Created by matsuosh on 2015/07/26.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import Alamofire
import Box
import Result
import XCGLogger

class Downloader: NSObject {

    let logger = XCGLogger.defaultInstance()

    static let sharedInstance = Downloader()

    func download(song: Song, handler: (Result<NSURL, NSError>) ->()) {
        if let destinationURL = FileManager.audioFileURL(song) {
            delete(destinationURL, handler: { (result) -> () in
                switch result {
                case .Success(let box):
                    if box.value {
                        Alamofire.download(.GET, song.previewURL) { (_, _) -> NSURL in
                            return destinationURL
                        }.response{ (_, _, _, error) -> () in
                            if let error = error {
                                self.logger.error(error.localizedDescription)
                                handler(.Failure(Box(error)))
                            } else {
                                self.logger.verbose("destinationURL: \(destinationURL)")
                                handler(.Success(Box(destinationURL)))
                            }
                        }
                    } else {
                        handler(.Failure(Box(NSError())))
                    }
                case .Failure(let box):
                    handler(.Failure(box))
                }
            })
        } else {
            handler(.Failure(Box(NSError())))
        }
    }

    func delete(fileURL: NSURL, handler: (Result<Bool, NSError>) ->()) {
        if let path = fileURL.path {
            logger.debug("path: \(path)")
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                var error: NSError?
                let result = NSFileManager.defaultManager().removeItemAtPath(path, error: &error)
                logger.debug("result: \(result)")
                if let error = error {
                    logger.debug("error: \(error)")
                    handler(.Failure(Box(error)))
                } else {
                    handler(.Success(Box(result)))
                }
            } else {
                logger.verbose("")
                handler(.Success(Box(true)))
            }
        } else {
            logger.verbose("")
            handler(.Failure(Box(NSError())))
        }
    }

}
