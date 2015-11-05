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
import PromiseKit
import XCGLogger

class VideoComposer: NSObject {

    let logger = XCGLogger.defaultInstance()

    static let sharedInstance = VideoComposer()

    func mixdown(videoURL videoURL: NSURL, audioURL: NSURL, duration: CMTime, handler: (Result<NSURL, NSError>) ->()) {
        logger.verbose("videoURL: \(videoURL.path!), audioURL: \(audioURL.path!)")

        let composition = AVMutableComposition()

        // ビデオのトラックの作成
        let videoAsset = AVURLAsset(URL: videoURL, options: nil)
        let videoRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        let videoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo).first!
        let compositionVideoTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        try! compositionVideoTrack.insertTimeRange(videoRange, ofTrack: videoTrack, atTime: kCMTimeZero)

        // 音声のトラックの作成
        let soundAsset = AVURLAsset(URL: audioURL, options: nil)
        let soundRange = CMTimeRangeMake(kCMTimeZero, duration)

        let float1 = CMTimeGetSeconds(videoAsset.duration)
        let float2 = CMTimeGetSeconds(duration)
        let float3 = float1 - float2
        logger.debug("float1: \(float1), float2: \(float2), float3: \(float3)")
        let atTime = CMTimeMakeWithSeconds(float3, 30)
        let soundTrack = soundAsset.tracksWithMediaType(AVMediaTypeAudio).first!
        let compositionSoundTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        try! compositionSoundTrack.insertTimeRange(soundRange, ofTrack: soundTrack, atTime: atTime)

        
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

        let textLayer: CATextLayer = {
            let layer = CATextLayer()
            layer.string = "Dubbidson"
            layer.font = R.font.teXGyreAdventorRegular(size: 10.0)!
            layer.fontSize = videoSize.width / 10.0
            layer.opacity = 0.5
            layer.alignmentMode = kCAAlignmentRight
            layer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height / 8.0)
            //layer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height)
            return layer
        }()
        let parentLayer = CALayer()
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height)
        
        let videoLayer = CALayer()
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(textLayer)
        
        logger.debug("textLayer.frame: \(textLayer.frame)")
        logger.debug("videoLayer.frame: \(videoLayer.frame)")
        logger.debug("parentLayer.frame: \(parentLayer.frame)")
        
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)

        
        let URL = FileIO.sharedInstance.createVideoFile()
        let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        session.outputURL = URL
        session.outputFileType = AVFileTypeQuickTimeMovie
        session.videoComposition = videoComposition
        session.exportAsynchronouslyWithCompletionHandler { () -> Void in
            switch session.status {
            case .Completed:
                handler(.Success(session.outputURL!))
            default:
                // TODO: エラー処理
                handler(.Failure(NSError(domain: "", code: 999, userInfo: nil)))
            }
            /*
            if session.status == AVAssetExportSessionStatus.Completed {
                handler(.Success(session.outputURL))
            } else {
                if let error = session.error {
                    self.logger.error(error.localizedDescription)
                    handler(.Failure(error))
                } else {
                    handler(.Failure(NSError()))
                }
            }
            */
        }
    }

    func mixdown(videoURL videoURL: NSURL, audioURL: NSURL, duration: CMTime) -> Promise<NSURL> {
        return Promise { fulfill, reject in
            self.mixdown(videoURL: videoURL, audioURL: audioURL, duration: duration) { (result) in
                switch result {
                case .Success(let URL):
                    fulfill(URL)
                case .Failure(let error):
                    reject(error)
                }
            }
        }
    }

}
