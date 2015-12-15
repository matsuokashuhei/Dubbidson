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

class Composer: NSObject {

    static let sharedInstance = Composer()

    let logger = XCGLogger.defaultInstance()

    func compose(videoURL videoURL: NSURL, audioURL: NSURL, duration: CMTime, handler: (Result<NSURL, NSError>) ->()) {
        logger.verbose("\nvideoURL: \(videoURL),\n audioURL: \(audioURL),\n duration: \(duration)")

        let composition = AVMutableComposition()

        // ビデオのトラックの作成
        let videoAsset = AVURLAsset(URL: videoURL, options: nil)
        let videoRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        let videoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo).first!
        let compositionVideoTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        do {
            try compositionVideoTrack.insertTimeRange(videoRange, ofTrack: videoTrack, atTime: kCMTimeZero)
        } catch let error as NSError {
            logger.error(error.description)
            handler(.Failure(error))
            return
        }

        // 音声のトラックの作成
        let soundAsset = AVURLAsset(URL: audioURL, options: nil)
        let soundRange = CMTimeRangeMake(kCMTimeZero, duration)

        let float1 = CMTimeGetSeconds(videoAsset.duration)
        let float2 = CMTimeGetSeconds(duration)
        let float3 = float1 - float2
        logger.verbose("float1: \(float1), float2: \(float2), float3: \(float3)")
        let atTime = CMTimeMakeWithSeconds(float3, 60)
        let soundTrack = soundAsset.tracksWithMediaType(AVMediaTypeAudio).first!
        let compositionSoundTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        do {
            try compositionSoundTrack.insertTimeRange(soundRange, ofTrack: soundTrack, atTime: atTime)
        } catch let error as NSError {
            logger.error(error.description)
            handler(.Failure(error))
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

        let textLayer: CATextLayer = {
            let layer = CATextLayer()
            //layer.string = "Dubbidson"
            layer.string = "DUBBIDSON"
            //layer.font = R.font.teXGyreAdventorRegular(size: 10.0)!
            //layer.font = UIFont(name: "Avenir Next", size: 12.0)!
            layer.fontSize = videoSize.width / 15.0
            layer.opacity = 0.5
            layer.alignmentMode = kCAAlignmentRight
            layer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height / 13.0)
            //layer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height)
            return layer
        }()
    
        let videoLayer = CALayer()
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height)

        let parentLayer = CALayer()
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(textLayer)
        
        logger.verbose("textLayer.frame: \(textLayer.frame)")
        logger.verbose("videoLayer.frame: \(videoLayer.frame)")
        logger.verbose("parentLayer.frame: \(parentLayer.frame)")
        
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)

        
        // TODO: ファイル
        let URL: NSURL
        if #available(iOS 9, *) {
            URL = NSURL(fileURLWithPath: videoURL.lastPathComponent!, isDirectory: false, relativeToURL: Directory.Documents.URL)
        } else {
            URL = NSURL(string: videoURL.lastPathComponent!, relativeToURL: Directory.Documents.URL)!
        }
        
        //let URL = FileIO.sharedInstance.createVideoFile()
        let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        session.outputURL = URL
        session.outputFileType = AVFileTypeQuickTimeMovie
        //session.outputFileType = AVFileTypeMPEG4
        session.videoComposition = videoComposition
        session.exportAsynchronouslyWithCompletionHandler { () -> Void in
            do {
                try NSFileManager.defaultManager().removeItemAtURL(videoURL)
            } catch let error as NSError {
                self.logger.error(error.description)
            }
            switch session.status {
            case .Completed:
                handler(.Success(session.outputURL!))
            default:
                if let error = session.error {
                    self.logger.error(error.description)
                    handler(.Failure(error))
                } else {
                    let error = NSError.errorWithAppError(.Unknown)
                    self.logger.error(error.description)
                    handler(.Failure(error))
                }
            }
        }
    }

    func compose(videoURL videoURL: NSURL, audioURL: NSURL, duration: CMTime) -> Promise<NSURL> {
        return Promise { fulfill, reject in
            self.compose(videoURL: videoURL, audioURL: audioURL, duration: duration) { (result: Result<NSURL, NSError>) in
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
