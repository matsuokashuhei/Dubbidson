//
//  RecordViewController.swift
//  Dubski
//
//  Created by matsuosh on 2015/08/16.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import AVKit
import UIKit

import Async
import Box
import GPUImage
import PromiseKit
import RealmSwift
import Result
import SVProgressHUD
import XCGLogger

class RecordViewController: UIViewController {

    @IBOutlet weak var durationLabel: UILabel! {
        didSet { durationLabel.hidden = true }
    }

    @IBOutlet weak var progressView: UIProgressView! {
        didSet {
            progressView.progress = 0.0
            progressView.hidden = true
        }
    }

    @IBOutlet weak var captureView: GPUImageView!

    @IBOutlet weak var songView: SongView! {
        didSet { songView.delegate = self }
    }

    @IBOutlet weak var recordButton: UIButton! {
        didSet {
            recordButton.addTarget(self, action: "recordButtonTapped", forControlEvents: .TouchUpInside)
            recordButton.enabled = false
        }
    }

    @IBOutlet weak var filterButton: UIButton! {
        didSet { filterButton.addTarget(self, action: "filterButtonTapped", forControlEvents: .TouchUpInside) }
    }

    let logger = XCGLogger.defaultInstance()

    let camera = Camera.sharedInstance

    var filter: Filterable! {
        didSet {
            if let prevFilter = oldValue {
                prevFilter.removeTarget(captureView)
            }
        }
    }

    var writer: GPUImageMovieWriter!

    let audioPlayer = AudioPlayer.sharedInstance

}

// MARK: - View controller
extension RecordViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // カメラのセットアップ
        filter = filters.first!
        camera.addTarget(filter)
        filter.addTarget(captureView)
        camera.startCapture()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - ビデオの保存
extension RecordViewController {

    func startRecording() {
        // Writerのの作成
        let fileURL = FileIO.recordingFileURL()
        writer = GPUImageMovieWriter(movieURL: fileURL, size: CGSize(width: captureView.frame.size.width, height: captureView.frame.size.width))
        writer.delegate = self
        //filterOperator.addTarget(writer)
        filter.addTarget(writer)
        // ボタンの画像の変更
        recordButton.setImage(R.image.lensOn, forState: .Normal)
        // ビデオの書き込みと音楽の再生と開始
        writer.startRecording()
        audioPlayer.play()
    }

    func finishRecording() {
        // Writeの終了
        writer.finishRecording()
        //filterOperator.filter.removeTarget(writer)
        filter.removeTarget(writer)
        // ボタンの画像の変更
        recordButton.setImage(R.image.lensOff, forState: .Normal)
    }

}

// MARK: - Actions
extension RecordViewController {

    func recordButtonTapped() {
        startRecording()
    }

    func filterButtonTapped() {
        performSegueWithIdentifier(R.segue.selectFilter, sender: nil)
    }

}

// MARK: - Navigation
extension RecordViewController {

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case R.segue.selectSong:
                let controller = segue.destinationViewController as! SongsViewController
                controller.delegate = self
            case R.segue.selectFilter:
                let controller = segue.destinationViewController as! FiltersViewController
                //controller.filter = filter
                controller.selectedFilter = filter
                controller.blendImage = songView.artworkImage
                controller.delegate = self
            case R.segue.watchVideo:
                let controller = segue.destinationViewController as! VideoViewController
                controller.video = sender as! Video
            default:
                super.prepareForSegue(segue, sender: sender)
            }
        }
    }

}

// MARK: - Song view delegate
extension RecordViewController: SongViewDelegate {

    func songViewTapped() {
        performSegueWithIdentifier(R.segue.selectSong, sender: nil)
    }

}

// MARK: - Songs view contorller delegate
extension RecordViewController: SongsViewControllerDelegate {

    func selectedSong(song: Song) {
        songView.song = song
        if TemporaryFile.exists(song.previewURL) {
            prepareToRecord(audioURL: FileIO.audioFileURL(song)!)
        }
        Downloader.sharedInstance.download(song) { (result) -> () in
            switch result {
            case .Success(let box):
                let audioURL = box.value
                TemporaryFile.create(audioURL)
                self.prepareToRecord(audioURL: audioURL)
            case .Failure(let box):
                let error = box.value
                self.logger.error(error.localizedDescription)
                Async.main {
                    SVProgressHUD.showErrorWithStatus(error.localizedDescription)
                }
            }
        }
    }

    func prepareToRecord(#audioURL: NSURL) {
        logger.debug("")
        recordButton.enabled = true
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay(audioURL)
    }

}

// MARK: - Audio player delegate
extension RecordViewController: AudioPlayerDelegate {

    func readyToPlay(item: AVPlayerItem) {
        durationLabel.text = formatTime(item.duration)
        durationLabel.hidden = false
        progressView.progress = 0.0
        progressView.hidden = false
    }

    func endTimeToPlay(item: AVPlayerItem) {
        finishRecording()
    }

    func playAtTime(time: CMTime, duration: CMTime) {
        let remainingTime = CMTimeGetSeconds(duration) - CMTimeGetSeconds(time)
        durationLabel.text = formatTime(CMTimeMakeWithSeconds(remainingTime, Int32(NSEC_PER_SEC)))
        progressView.progress = Float(CMTimeGetSeconds(time)) / Float(CMTimeGetSeconds(duration))
    }

    func formatTime(time: CMTime) -> String {
        /*
        let components = NSDateComponents()
        let seconds = CMTimeGetSeconds(time)
        if isnormal(seconds) {
            //components.second = Int(seconds)
            components.second = Int(round(seconds))
        } else {
            components.second = 0
        }
        let formatter = NSDateComponentsFormatter()
        formatter.zeroFormattingBehavior = .Pad
        formatter.allowedUnits = NSCalendarUnit.CalendarUnitSecond
        return formatter.stringFromDateComponents(components) ?? "0"
        */
        let seconds = CMTimeGetSeconds(time)
        logger.debug("seconds: \(seconds)")
        if isnormal(seconds) {
           return "\(Int(round(seconds))) sec"
        } else {
            return "0 sec"
        }
    }

}

// MARK: - Filters view controller delegate
extension RecordViewController: FiltersViewControllerDeleage {

    func didSelectFilter(filter: Filterable) {
        if self.filter.name != filter.name {
            self.filter = filter
            filter.addTarget(captureView)
        }
    }

    func didDeselectFilter() {
        filter.addTarget(captureView)
    }
}

// MARK: - GPU image movie writer delegate
extension RecordViewController: GPUImageMovieWriterDelegate {

    func movieRecordingCompleted() {
        logger.verbose("")
        let song = songView.song
        if let recordingURL = writer.assetWriter.outputURL {
            if let audioURL = FileIO.audioFileURL(song) {
                Mixer.sharedInstance.mixdown(videoURL: recordingURL, audioURL: audioURL).then { (videoURL) in
                    let id = videoURL.lastPathComponent!.stringByDeletingPathExtension
                    return self.generateThumbnail(videoURL).then { (image) in
                        return Promise<String> { (fulfill, reject) in
                            let thumbnailURL = FileIO.fileURL(.Documents, filename: "\(id).png")!
                            if UIImagePNGRepresentation(image).writeToFile(thumbnailURL.path!, atomically: true) {
                                fulfill(id)
                            } else {
                                let error = Error.unknown()
                                self.logger.error(error.localizedDescription)
                                reject(error)
                            }
                        }
                    }
                }.then { (id: String) -> () in
                    let video = Video.create(id, song: song)
                    self.performSegueWithIdentifier(R.segue.watchVideo, sender: video)
                    FileIO.delete(recordingURL)
                }.catch { error in
                    self.logger.error("error: \(error.localizedDescription)")
                    SVProgressHUD.showErrorWithStatus(error.localizedDescription)
                }
            } else {
                let error = Error.unknown()
                self.logger.error(error.localizedDescription)
                SVProgressHUD.showErrorWithStatus(error.localizedDescription)
            }
        } else {
            let error = Error.unknown()
            self.logger.error(error.localizedDescription)
            SVProgressHUD.showErrorWithStatus(error.localizedDescription)
        }
    }

    func movieRecordingFailedWithError(error: NSError!) {
        logger.error("error: \(error.localizedDescription)")
        SVProgressHUD.showErrorWithStatus(error.localizedDescription)
    }

    func generateThumbnail(videoURL: NSURL) -> Promise<UIImage> {
        return Promise { (fulfill, reject) in
            if let asset = AVAsset.assetWithURL(videoURL) as? AVAsset {
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                let time = CMTimeMake(1, 30)
                var error: NSError?
                if let image = generator.copyCGImageAtTime(time, actualTime: nil, error: &error) {
                    if let thumbnail = UIImage(CGImage: image) {
                        fulfill(thumbnail)
                    } else {
                        let error = Error.unknown()
                        self.logger.error(error.localizedDescription)
                        reject(error)
                    }
                } else {
                    if let error = error {
                        self.logger.error(error.localizedDescription)
                        reject(error)
                    } else {
                        let error = Error.unknown()
                        self.logger.error(error.localizedDescription)
                        reject(error)
                    }
                }
            } else {
                let error = Error.unknown()
                self.logger.error(error.localizedDescription)
                reject(error)
            }
        }
    }
}