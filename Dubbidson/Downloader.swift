//
//  Downloader.swift
//  GPUImageTest
//
//  Created by matsuosh on 2015/07/26.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import Alamofire
import PromiseKit
import Result
import XCGLogger

class Downloader: NSObject {

    let logger = XCGLogger.defaultInstance()

    static let sharedInstance = Downloader()

    func download(song: Song, handler: (ATResult<NSURL, NSError>.t) ->()) {
        logger.debug("song: name: \(song.name), title: \(song.artist) をダウンロードします。")
        guard let destinationURL = song.downloadFileURL else {
            handler(.Failure(NSError.errorWithAppError(.OptionalValueIsNone)))
            return
        }
        switch FileIO.sharedInstance.delete(destinationURL) {
        case .Success(_):
            NetworkIndicator.sharedInstance.show()
            Alamofire.download(.GET, song.previewURL) { (_, _) -> NSURL in
                return destinationURL
            }.response{ (_, _, _, error) -> () in
                NetworkIndicator.sharedInstance.dismiss()
                if let error = error as? NSError {
                    self.logger.error(error.description)
                    handler(.Failure(error))
                } else {
                    self.logger.verbose("destinationURL: \(destinationURL)")
                    handler(.Success(destinationURL))
                }
            }
        case .Failure(let error):
            handler(.Failure(error))
        }
    }

    func download(song: Song) -> Promise<NSURL> {
        return Promise { (fulfill, reject) in
            download(song, handler: { (result) -> () in
                switch result {
                case .Success(let donwloadURL):
                    fulfill(donwloadURL)
                case .Failure(let error):
                    reject(error)
                }
            })
        }
    }

}
