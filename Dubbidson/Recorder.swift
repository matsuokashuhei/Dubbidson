//
//  Recorder.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/11/23.
//  Copyright © 2015年 matsuosh. All rights reserved.
//

import Alamofire
import GPUImage
import PromiseKit
import XCGLogger

protocol RecorderDelegate {
    func readyToRecord(item: AVPlayerItem)
    func startExporting()
    func recordingCompleted(video: Video)
    func recordingFailed(error: NSError)
    func playbackTime(time: CMTime, duration: CMTime)
}

class Recorder: NSObject {

    let logger = XCGLogger.defaultInstance()

    var audioPlayer = AudioPlayer.sharedInstance

    var delegate: RecorderDelegate?

    var song: Song! {
        didSet {
            download(song)
        }
    }
    var filter: Filterable!
    var writer: GPUImageMovieWriter!

    func prepareToRecord(song: Song) {
        logger.verbose("song: \(song)")
        self.song = song
    }

    func startRecording(size size: CGSize) {
        logger.verbose("")
        // ファイルの準備
        // TODO: ファイル
        let movieURL = touchMovieURL()
        writer = GPUImageMovieWriter(movieURL: movieURL, size: size)
        writer.delegate = self
        // ライターの準備
        filter.addTarget(writer)
        writer.startRecording()
        // 音楽の再生
        audioPlayer.startToPlay()
    }

    func finishRecording() {
        logger.verbose("")
        // ライターの終了
        writer.finishRecording()
        filter.removeTarget(writer)
    }

    func stopRecording() {
        logger.verbose("")
        // 音楽の停止
        audioPlayer.stop()
        // レコーディングの終了
        finishRecording()
    }

    private func download(song: Song) -> () {
        logger.verbose("song: \(song)")
        // TODO: ファイル
        guard let destinationURL = song.audioFileURL else {
            logger.warning("song.audioFileURL is nil.")
            return
        }
        logger.verbose("song.audioFileURL: \(song.audioFileURL)")
        if NSFileManager.defaultManager().fileExistsAtPath(destinationURL.path!) {
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay(destinationURL)
            return
        }
        Alamofire.download(.GET, song.previewURL) { (_, _) -> NSURL in
            return destinationURL
        }.response { [weak self] (_, _, _, error) -> Void in
            if let error = error {
                self?.logger.error(error.description)
                // TODO: エラー処理
                return
            }
            guard let _ = destinationURL.lastPathComponent else {
                // TODO: エラー処理
                self?.logger.warning("destinationURL.lastPathComponent is nil")
                return
            }
            song.save()
            self?.audioPlayer.delegate = self
            self?.audioPlayer.prepareToPlay(destinationURL)
        }
    }

    private func touchMovieURL() -> NSURL? {
        // TODO: ファイルの管理を整理する
        logger.verbose("")
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = "\(formatter.stringFromDate(NSDate())).mp4"
        if #available(iOS 9, *) {
            return NSURL(fileURLWithPath: fileName, isDirectory: false, relativeToURL: Directory.Temporary.URL)
        } else {
            return NSURL(string: fileName, relativeToURL: Directory.Temporary.URL)
        }
    }

}

extension Recorder: AudioPlayerDelegate {

    func readyToPlay(item item: AVPlayerItem) {
        logger.verbose("")
        delegate?.readyToRecord(item)
    }

    func endTimeToPlay(item: AVPlayerItem) {
        logger.verbose("")
        finishRecording()
    }

    func playbackTime(time: CMTime, duration: CMTime) {
        delegate?.playbackTime(time, duration: duration)
    }
}

extension Recorder: GPUImageMovieWriterDelegate {

    func movieRecordingCompleted() {
        logger.verbose("")
        guard let audioURL = song.audioFileURL where NSFileManager.defaultManager().fileExistsAtPath(audioURL.path!) else {
            return
        }
        let videoURL = writer.assetWriter.outputURL
        let duration = audioPlayer.item.currentTime()
        delegate?.startExporting()
        /*
        Composer.sharedInstance.compose(videoURL: videoURL, audioURL: audioURL, duration: duration).then { (videoURL, thumbnailImage) -> () in
            let video: Video = {
                let video = Video()
                video.fileName = videoURL.lastPathComponent!
                video.thumbnailData = UIImagePNGRepresentation(thumbnailImage)!
                video.song = self.song
                video.save()
                return video
            }()
            self.delegate?.recordingCompleted(video)
        }.finally {
            self.audioPlayer.stop()
        }.catch_ { error in
            self.logger.error(error.description)
            self.movieRecordingFailedWithError(error)
        }
        */
        let video = Video()
        video.song = song
        Composer.sharedInstance.compose(videoURL: videoURL, audioURL: audioURL, duration: duration).then { (URL) in
            video.fileName = URL.lastPathComponent!
            return self.generateThumbnail(URL)
        }.then { (image: UIImage) -> () in
            video.thumbnailData = UIImagePNGRepresentation(image)
            video.save()
            self.delegate?.recordingCompleted(video)
        }.catch_ { error in
            self.logger.error(error.description)
            self.movieRecordingFailedWithError(error)
        }
    }

    func movieRecordingFailedWithError(error: NSError!) {
        logger.verbose("")
        logger.error(error.description)
        delegate?.recordingFailed(error)
    }

    private func generateThumbnail(videoURL: NSURL, handler: (Result<UIImage, NSError>) -> ()) {
        let asset = AVAsset(URL: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        do {
            let thumbnail = try generator.copyCGImageAtTime(asset.duration, actualTime: nil)
            handler(.Success(UIImage(CGImage: thumbnail)))
        } catch let error as NSError {
            handler(.Failure(error))
        }
    }

    private func generateThumbnail(videoURL: NSURL) -> Promise<UIImage> {
        return Promise { fulfill, reject in
            generateThumbnail(videoURL) { (result) -> () in
                switch result {
                case .Success(let image):
                    return fulfill(image)
                case .Failure(let error):
                    return reject(error)
                }
            }
        }
    }
}