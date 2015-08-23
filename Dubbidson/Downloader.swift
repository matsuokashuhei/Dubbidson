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
        if let destinationURL = FileIO.audioFileURL(song) {
            switch FileIO.delete(destinationURL) {
            case .Success(let box):
                NetworkIndicator.sharedInstance.show()
                Alamofire.download(.GET, song.previewURL) { (_, _) -> NSURL in
                    return destinationURL
                }.response{ (_, _, _, error) -> () in
                    NetworkIndicator.sharedInstance.dismiss()
                    if let error = error {
                        self.logger.error(error.localizedDescription)
                        handler(.Failure(Box(error)))
                    } else {
                        self.logger.verbose("destinationURL: \(destinationURL)")
                        handler(.Success(Box(destinationURL)))
                    }
                }
            case .Failure(let box):
                handler(.Failure(box))
                //handler(.Failure(Box(Error.unknown())))
            }
        } else {
            handler(.Failure(Box(Error.unknown())))
        }
    }

}
