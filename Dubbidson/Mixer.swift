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
import XCGLogger

class Mixer: NSObject {

    let logger = XCGLogger.defaultInstance()

    static let sharedInstance = Mixer()

    var outputURL: NSURL {
        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let stringFromDate = formatter.stringFromDate(NSDate())
        //return directory.URLByAppendingPathComponent("\(stringFromDate).m4v")
        return directory.URLByAppendingPathComponent("\(stringFromDate).mov")
    }

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

        let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        session.outputURL = outputURL
        session.outputFileType = AVFileTypeQuickTimeMovie
        session.videoComposition = videoComposition
        session.exportAsynchronouslyWithCompletionHandler { () -> Void in
            if session.status == AVAssetExportSessionStatus.Completed {
                handler(.Success(Box(session.outputURL)))
                //handler(.Success(Box(self.outputURL)))
            } else {
                if let error = session.error {
                    self.logger.error(error.localizedDescription)
                    handler(.Failure(Box(error)))
                }
            }
        }
    }

}
