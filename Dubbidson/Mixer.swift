//
//  Mixer.swift
//  GPUImageTest
//
//  Created by matsuosh on 2015/07/26.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import AVFoundation
import Foundation

import Result
import Box
import PromiseKit
import XCGLogger

class Mixer: NSObject {

    let logger = XCGLogger.defaultInstance()

    static let sharedInstance = Mixer()

    /*
    func mixdown(#videoURL: NSURL, audioURL: NSURL) -> Promise<(videoURL: NSURL, thumbnailURL: NSURL)> {
        return Promise { (filfull, reject) in
            mixdown(videoURL: videoURL, audioURL: audioURL).then { (outputURL: NSURL) in
                self.saveThumbnail(outputURL).then { (thumbnailURL) in
                    filfull(videoURL: outputURL, thumbnailURL: thumbnailURL)
                }.catch { error in
                    reject(error)
                }
            }.catch { error in
                reject(error)
            }
        }
    }
    */

    func mixdown(#videoURL: NSURL, audioURL: NSURL, handler: (Result<NSURL, NSError>) ->()) {
        logger.verbose("videoURL: \(videoURL.path!), audioURL: \(audioURL.path!)")
        var error: NSError?

        let composition = AVMutableComposition()

        let videoAsset = AVURLAsset(URL: videoURL, options: nil)
        let videoRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        CMTimeGetSeconds(videoAsset.duration)
        let videoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo).first as! AVAssetTrack
        let compositionVideoTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        compositionVideoTrack.insertTimeRange(videoRange, ofTrack: videoTrack, atTime: kCMTimeZero, error: &error)
        if let error = error {
            self.logger.error(error.localizedDescription)
            handler(.Failure(Box(error)))
            return
        }

        let soundAsset = AVURLAsset(URL: audioURL, options: nil)
        let soundRange = CMTimeRangeMake(kCMTimeZero, soundAsset.duration)

        let float1 = CMTimeGetSeconds(videoAsset.duration)
        let float2 = CMTimeGetSeconds(soundAsset.duration)
        let float3 = float1 - float2
        let atTime = CMTimeMakeWithSeconds(float3, 30)
        let soundTrack = soundAsset.tracksWithMediaType(AVMediaTypeAudio).first as! AVAssetTrack
        let compositionSoundTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        compositionSoundTrack.insertTimeRange(soundRange, ofTrack: soundTrack, atTime: atTime, error: &error)
        if let error = error {
            self.logger.error(error.localizedDescription)
            handler(.Failure(Box(error)))
            return
        }

        var videoSize = videoTrack.naturalSize
        let transform = videoTrack.preferredTransform
        if transform.a == 0.0 && transform.d == 0.0 && (transform.b == 1.0 || transform.b == -1.0) && (transform.c == 1.0 || transform.c == -1.0) {
            videoSize = CGSizeMake(videoSize.height, videoSize.width)
        }
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = videoRange
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        layerInstruction.setTransform(transform, atTime: kCMTimeZero)
        instruction.layerInstructions = [layerInstruction]

        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.instructions = [instruction]
        videoComposition.frameDuration = CMTimeMake(1, 30)

        let URL = FileIO.videoFileURL()
        let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        session.outputURL = URL
        session.outputFileType = AVFileTypeQuickTimeMovie
        session.videoComposition = videoComposition
        session.exportAsynchronouslyWithCompletionHandler { () -> Void in
            if session.status == AVAssetExportSessionStatus.Completed {
                handler(.Success(Box(session.outputURL)))
            } else {
                if let error = session.error {
                    self.logger.error(error.localizedDescription)
                    handler(.Failure(Box(error)))
                } else {
                    handler(.Failure(Box(NSError())))
                }
            }
        }
    }

    func mixdown(#videoURL: NSURL, audioURL: NSURL) -> Promise<NSURL> {
        return Promise { fulfill, reject in
            self.mixdown(videoURL: videoURL, audioURL: audioURL) { (result) in
                switch result {
                case .Success(let box):
                    fulfill(box.value)
                case .Failure(let box):
                    reject(box.value)
                }
            }
        }
    }

    /*
    private func generateThumbnail(videoURL: NSURL) -> Result<UIImage, NSError> {
        if let asset = AVAsset.assetWithURL(videoURL) as? AVAsset {
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let time = CMTimeMake(1, 30)
            var error: NSError?
            if let image = generator.copyCGImageAtTime(time, actualTime: nil, error: &error) {
                if let thumbnail = UIImage(CGImage: image) {
                    return .Success(Box(thumbnail))
                } else {
                    return .Failure(Box(NSError()))
                }
            } else {
                return .Failure(Box(NSError()))
            }
        } else {
            return .Failure(Box(NSError()))
        }
    }

    private func generateThumbnail(videoURL: NSURL) -> Promise<UIImage> {
        return Promise { (filfull, reject) in
            let result: Result<UIImage, NSError> = self.generateThumbnail(videoURL)
            switch result {
            case .Success(let box):
                filfull(box.value)
            case .Failure(let box):
                reject(box.value)
            }
        }
    }

    func generateThumbnail(videoURL: NSURL) -> Promise<UIImage> {
        return Promise { (fulfill, reject) in
            if let asset = AVAsset.assetWithURL(videoURL) as? AVAsset {
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                let time = CMTimeMake(1, 30)
                var error: NSError?
                if let error = error {
                    reject(NSError())
                }
                if let image = generator.copyCGImageAtTime(time, actualTime: nil, error: &error) {
                    if let thumbnail = UIImage(CGImage: image) {
                        fulfill(thumbnail)
                    } else {
                        reject(NSError())
                    }
                } else {
                    reject(NSError())
                }
            } else {
                reject(NSError())
            }
        }
    }

    func saveThumbnail(videoURL: NSURL) -> Promise<NSURL> {
        return Promise { (fulfill, reject) in
            if let videoFilename = videoURL.lastPathComponent {
                let timestamp = videoFilename.stringByDeletingPathExtension
                let thumbnailFilename = timestamp.stringByAppendingPathExtension("png")
                self.generateThumbnail(videoURL).then { (image) -> () in
                    let thumbnailURL = FileIO.fileURL(.Documents, filename: thumbnailFilename)!
                    if UIImagePNGRepresentation(image).writeToFile(thumbnailURL.absoluteString!, atomically: true) {
                        fulfill(thumbnailURL)
                    } else {
                        reject(NSError())
                    }
                }.catch { error in
                    reject(error)
                }
            } else {
                reject(NSError())
            }
        }
    }
    */

}
