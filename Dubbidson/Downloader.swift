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
import PromiseKit
import Result
import XCGLogger

class Downloader: NSObject {

    let logger = XCGLogger.defaultInstance()

    static let sharedInstance = Downloader()

    func download(song: Song, handler: (Result<NSURL, NSError>) ->()) {
        logger.debug("song: name: \(song.name), title: \(song.artist) をダウンロードします。")
        if let destinationURL = FileIO.sharedInstance.audioFileURL(song) {
            switch FileIO.sharedInstance.delete(destinationURL) {
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
            }
        } else {
            handler(.Failure(Box(Error.unknown())))
        }
    }

    func download(song: Song) -> Promise<NSURL> {
        return Promise { (fulfill, reject) in
            download(song, handler: { (result) -> () in
                switch result {
                case .Success(let box):
                    fulfill(box.value)
                case .Failure(let box):
                    reject(box.value)
                }
            })
        }
    }

}
