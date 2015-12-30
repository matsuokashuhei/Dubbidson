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
        let videoAsset = AVURLAsset(URL: videoURL)
        let videoRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        guard let videoTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo).first else {
            handler(.Failure(NSError.errorWithAppError(AppError.OptionalIsNil("videoAsset.tracksWithMediaType(AVMediaTypeVideo).first"))))
            return
        }
        let compositionVideoTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        do {
            try compositionVideoTrack.insertTimeRange(videoRange, ofTrack: videoTrack, atTime: kCMTimeZero)
        } catch let error as NSError {
            logger.error(error.description)
            handler(.Failure(error))
            return
        }

        // 音声のトラックの作成
        let audioAsset = AVURLAsset(URL: audioURL)
        let audioRange = CMTimeRangeMake(kCMTimeZero, duration)
        /*
        let float1 = CMTimeGetSeconds(videoAsset.duration)
        let float2 = CMTimeGetSeconds(duration)
        let float3 = float1 - float2
        logger.verbose("float1: \(float1), float2: \(float2), float3: \(float3)")
        let atTime = CMTimeMakeWithSeconds(float3, 60)
        */
        let atTime = CMTimeMakeWithSeconds(
            CMTimeGetSeconds(videoAsset.duration) - CMTimeGetSeconds(duration), 60)
        guard let audioTrack = audioAsset.tracksWithMediaType(AVMediaTypeAudio).first else {
            handler(.Failure(NSError.errorWithAppError(AppError.OptionalIsNil("audioAsset.tracksWithMediaType(AVMediaTypeAudio).first"))))
            return
        }
        let compositionAudioTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        do {
            try compositionAudioTrack.insertTimeRange(audioRange, ofTrack: audioTrack, atTime: atTime)
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

        let videoComposition: AVMutableVideoComposition = {
            let videoComposition = AVMutableVideoComposition()
            videoComposition.renderSize = videoSize
            videoComposition.frameDuration = CMTimeMake(1, 30)
            // ロゴの埋め込み
            videoComposition.animationTool = {
                let videoLayer: CALayer = {
                    let layer = CALayer()
                    layer.frame = CGRect(origin: CGPointZero, size: videoSize)
                    return layer
                }()
                let parentLayer: CALayer = {
                    let layer = CALayer()
                    layer.frame = CGRect(origin: CGPointZero, size: videoSize)
                    layer.addSublayer(videoLayer)
                    layer.addSublayer({
                        let layer = CALayer()
                        layer.contents = R.image.appLogo!.CGImage!
                        layer.frame = CGRectMake(videoSize.width - 70, 10, 60, 60)
                        layer.opacity = 0.5
                        return layer
                    }())
                    return layer
                }()
                return AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
            }()
            videoComposition.instructions = {
                let instruction = AVMutableVideoCompositionInstruction()
                instruction.timeRange = videoRange
                instruction.layerInstructions = [AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)]
                return [instruction]
            }()
            return videoComposition
        }()
        /*
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = videoRange
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        layerInstruction.setTransform(transform, atTime: kCMTimeZero)
        instruction.layerInstructions = [layerInstruction]

        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.instructions = [instruction]
        videoComposition.frameDuration = CMTimeMake(1, 30)
        */

        /*
        let imageLayer: CALayer = {
            let layer = CALayer()
            layer.frame = CGRectMake(videoSize.width - 70, 10, 60, 60)
            layer.contents = R.image.appLogo!.CGImage!
            return layer
        }()
    
        let videoLayer = CALayer()
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height)

        let parentLayer = CALayer()
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height)
        parentLayer.addSublayer(videoLayer)
        //parentLayer.addSublayer(textLayer)
        parentLayer.addSublayer(imageLayer)
        //parentLayer.addSublayer(UIImageView(image: R.image.appLogo!).layer)
        
//        logger.verbose("textLayer.frame: \(textLayer.frame)")
        logger.verbose("videoLayer.frame: \(videoLayer.frame)")
        logger.verbose("parentLayer.frame: \(parentLayer.frame)")
        
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
        */

        
        // TODO: ファイル
        let URL: NSURL
        if #available(iOS 9, *) {
            URL = NSURL(fileURLWithPath: videoURL.lastPathComponent!, isDirectory: false, relativeToURL: Directory.Documents.URL)
        } else {
            URL = NSURL(string: videoURL.lastPathComponent!, relativeToURL: Directory.Documents.URL)!
        }
        
        guard let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            handler(.Failure(NSError.errorWithAppError(AppError.OptionalIsNil("AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)"))))
            return
        }
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

    func overlayLogoOnVideo(URL: NSURL, handler: (Result<NSURL, NSError>) -> ()) {
        do {
            let composition = AVMutableComposition()

            let asset = AVURLAsset(URL: URL)
            let range = CMTimeRange(start: kCMTimeZero, duration: asset.duration)
            
            guard
                let videoTrack = asset.tracksWithMediaType(AVMediaTypeVideo).first,
                let audioTrack = asset.tracksWithMediaType(AVMediaTypeAudio).first else {
                handler(.Failure(NSError.errorWithAppError(AppError.Unknown)))
                return
            }
            let compositionVideoTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
            try compositionVideoTrack.insertTimeRange(range, ofTrack: videoTrack, atTime: kCMTimeZero)
            
            let compositionAudioTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
            try compositionAudioTrack.insertTimeRange(range, ofTrack: audioTrack, atTime: kCMTimeZero)
            
        
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
            
            let videoComposition: AVMutableVideoComposition = {
                let videoComposition = AVMutableVideoComposition()
                videoComposition.renderSize = compositionVideoTrack.naturalSize
                videoComposition.frameDuration = CMTimeMake(1, 60)
                videoComposition.animationTool = {
//                    let imageLayer: CALayer = {
//                        let layer = CALayer()
//                        layer.contents = R.image.appLogo!.CGImage!
//                        layer.frame = CGRectMake(10, 10, 60, 60)
//                        layer.opacity = 0.9
//                        return layer
//                    }()
                    let videoLayer: CALayer = {
                        let layer = CALayer()
                        layer.frame = CGRect(origin: CGPointMake(0, 0), size: videoTrack.naturalSize)
                        return layer
                    }()
                    let parentLayer: CALayer = {
                        let layer = CALayer()
                        layer.frame = CGRect(origin: CGPointMake(0, 0), size: videoTrack.naturalSize)
                        layer.addSublayer(videoLayer)
                        //layer.addSublayer(imageLayer)
                        layer.addSublayer({
                            let layer = CALayer()
                            layer.contents = R.image.appLogo!.CGImage!
                            layer.frame = CGRectMake(10, 10, 60, 60)
                            layer.opacity = 0.9
                            return layer
                        }())
                        return layer
                    }()
                    return AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
                }()
                videoComposition.instructions = {
                    let instruction = AVMutableVideoCompositionInstruction()
                    instruction.timeRange = CMTimeRange(start: kCMTimeZero, duration: composition.duration)
                    instruction.layerInstructions = {
                        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
                        return [layerInstruction]
                    }()
                    return [instruction]
                }()
                return videoComposition
            }()

            guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
                handler(.Failure(NSError.errorWithAppError(AppError.Unknown)))
                return
            }
            exportSession.videoComposition = videoComposition
            exportSession.outputFileType = AVFileTypeQuickTimeMovie
            exportSession.outputURL = touchMovieURL()!
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronouslyWithCompletionHandler { () -> Void in
                switch exportSession.status {
                case .Completed:
                    handler(.Success(exportSession.outputURL!))
                default:
                    if let error = exportSession.error {
                        self.logger.error(error.description)
                        handler(.Failure(error))
                    } else {
                        let error = NSError.errorWithAppError(.Unknown)
                        self.logger.error(error.description)
                        handler(.Failure(error))
                    }
                }
            }
        } catch let error as NSError {
            handler(.Failure(error))
        }
    }

    func overlayLogoOnVideo(URL: NSURL) -> Promise<NSURL> {
        return Promise { fulfill, reject in
            self.overlayLogoOnVideo(URL) { result in
                switch result {
                case .Success(let URL):
                    return fulfill(URL)
                case .Failure(let error):
                    reject(error)
                }
            }
        }
    }

    private func touchMovieURL() -> NSURL? {
        // TODO: ファイルの管理を整理する
        logger.verbose("")
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = "\(formatter.stringFromDate(NSDate())).mp4"
        if #available(iOS 9, *) {
            return NSURL(fileURLWithPath: fileName, isDirectory: false, relativeToURL: Directory.Documents.URL)
        } else {
            return NSURL(string: fileName, relativeToURL: Directory.Documents.URL)
        }
    }
}
