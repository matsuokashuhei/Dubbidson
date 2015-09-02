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

class VideoComposer: NSObject {

    let logger = XCGLogger.defaultInstance()

    static let sharedInstance = VideoComposer()

    func mixdown(#videoURL: NSURL, audioURL: NSURL, duration: CMTime, handler: (Result<NSURL, NSError>) ->()) {
        logger.verbose("videoURL: \(videoURL.path!), audioURL: \(audioURL.path!)")
        var error: NSError?

        let composition = AVMutableComposition()

        let videoAsset = AVURLAsset(URL: videoURL, options: nil)
        let videoRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        let videoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo).first as! AVAssetTrack
        let compositionVideoTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        compositionVideoTrack.insertTimeRange(videoRange, ofTrack: videoTrack, atTime: kCMTimeZero, error: &error)
        if let error = error {
            self.logger.error(error.localizedDescription)
            handler(.Failure(Box(error)))
            return
        }

        let soundAsset = AVURLAsset(URL: audioURL, options: nil)
        //let soundRange = CMTimeRangeMake(kCMTimeZero, soundAsset.duration)
        let soundRange = CMTimeRangeMake(kCMTimeZero, duration)

        let float1 = CMTimeGetSeconds(videoAsset.duration)
        //let float2 = CMTimeGetSeconds(soundAsset.duration)
        let float2 = CMTimeGetSeconds(duration)
        let float3 = float1 - float2
        logger.debug("float1: \(float1), float2: \(float2), float3: \(float3)")
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

        let URL = FileIO.sharedInstance.createVideoFile()
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

    func mixdown(#videoURL: NSURL, audioURL: NSURL, duration: CMTime) -> Promise<NSURL> {
        return Promise { fulfill, reject in
            self.mixdown(videoURL: videoURL, audioURL: audioURL, duration: duration) { (result) in
                switch result {
                case .Success(let box):
                    fulfill(box.value)
                case .Failure(let box):
                    reject(box.value)
                }
            }
        }
    }

}
