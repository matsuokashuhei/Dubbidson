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
import GPUImage
import PromiseKit
import RealmSwift
import Result
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

    @IBOutlet weak var countdownView: CountdownView! {
        didSet {
            countdownView.hidden = true
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

    var isRecording: Bool {
        return recordButton.imageView?.image == R.image.recOn
    }

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
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - Actions
extension RecordViewController {

    func recordButtonTapped() {
        if isRecording == false {
            CountdownTimer.sharedInstance.showWithSeconds(4.0) { () in
                self.startRecording()
            }
        } else {
            stopRecording()
        }
    }

    func filterButtonTapped() {
        // レコーディング中は無効にする。
        if isRecording {
            return
        }
        performSegueWithIdentifier(R.segue.selectFilter, sender: nil)
    }

}

// MARK: - Navigation
extension RecordViewController {

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case R.segue.selectSong:
            recordButton.enabled = false
            let controller = segue.destinationViewController as! SongsViewController
            controller.delegate = self
        case R.segue.selectFilter:
            let controller = segue.destinationViewController as! FiltersViewController
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

// MARK: - ビデオの保存
extension RecordViewController {

    func startRecording() {
        logger.verbose("")
        // Writerのの作成
        let fileURL = FileIO.sharedInstance.createRecordingFile()
        writer = GPUImageMovieWriter(movieURL: fileURL, size: CGSize(width: captureView.frame.size.width, height: captureView.frame.size.width))
        writer.delegate = self
        filter.addTarget(writer)
        // ボタンの画像の変更
        recordButton.setImage(R.image.recOn, forState: .Normal)
        // ビデオの書き込みと音楽の再生と開始
        writer.startRecording()
        audioPlayer.startToPlay()
    }

    func finishRecording() {
        // Writeの終了
        writer.finishRecording()
        filter.removeTarget(writer)
        // ボタンの画像の変更
        recordButton.setImage(R.image.recOff, forState: .Normal)
    }

    func stopRecording() {
        audioPlayer.pause()
        finishRecording()
    }

}

// MARK: - Song view delegate
extension RecordViewController: SongViewDelegate {

    func songViewTapped() {
        // レコーディング中は無効にする。
        if isRecording {
            return
        }
        performSegueWithIdentifier(R.segue.selectSong, sender: nil)
    }
    
    func readyToPlay(song: Song) {
        prepareToRecord(audioURL: song.downloadFileURL!)
    }

}

// MARK: - Songs view contorller delegate
extension RecordViewController: SongsViewControllerDelegate {

    func didSelectSong(song: Song) {
        songView.song = song
    }

    func didNotSelectSong() {
        if let song = songView.song {
            didSelectSong(song)
        }
    }

    func prepareToRecord(audioURL audioURL: NSURL) {
        logger.debug("audioURL: \(audioURL)")
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

    func playbackTime(time: CMTime, duration: CMTime) {
        let remainingTime = CMTimeGetSeconds(duration) - CMTimeGetSeconds(time)
        durationLabel.text = formatTime(CMTimeMakeWithSeconds(remainingTime, Int32(NSEC_PER_SEC)))
        progressView.progress = Float(CMTimeGetSeconds(time)) / Float(CMTimeGetSeconds(duration))
    }

    func endTimeToPlay(item: AVPlayerItem) {
        finishRecording()
    }

    private func formatTime(time: CMTime) -> String {
        let seconds = CMTimeGetSeconds(time)
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
        guard let audioURL = song.downloadFileURL else {
            let error = NSError.errorWithAppError(.OptionalValueIsNone)
            logger.error(error.description)
            Notificator.sharedInstance.showError(error)
            return
        }
        let recordingURL = writer.assetWriter.outputURL
        Notificator.sharedInstance.showLoading()
        let currentTime = audioPlayer.item.currentTime()
        VideoComposer.sharedInstance.mixdown(videoURL: recordingURL, audioURL: audioURL, duration: currentTime).then { (videoURL) in
            let id = (videoURL.lastPathComponent! as NSString).stringByDeletingPathExtension
            return self.generateThumbnail(videoURL).then { (image) in
                return Promise<String> { (fulfill, reject) in
                    let thumbnailURL = FileIO.sharedInstance.fileURL(.Documents, filename: "\(id).png")!
                    FileIO.sharedInstance.save(image, fileURL: thumbnailURL)
                    if let image = UIImagePNGRepresentation(image) {
                        image.writeToFile(thumbnailURL.path!, atomically: true)
                        fulfill(id)
                    } else {
                        let error = NSError.errorWithAppError(.UIImagePNGRepresentationIsFailed)
                        self.logger.error(error.description)
                        reject(error)
                    }
                }
            }
        }.then { (id: String) -> () in
            let video = Video.create(id, song: song)
            self.performSegueWithIdentifier(R.segue.watchVideo, sender: video)
        }.finally {
            self.audioPlayer.stop()
            self.progressView.progress = 0.0
            self.durationLabel.text = "30 sec"
            FileIO.sharedInstance.delete(recordingURL)
            Notificator.sharedInstance.dismissLoading()
        }.catch_ { error in
            self.logger.error("error: \(error.localizedDescription)")
            Notificator.sharedInstance.showError(error)
        }
    }

    func movieRecordingFailedWithError(error: NSError!) {
        logger.error("error: \(error.localizedDescription)")
        Notificator.sharedInstance.showError(error)
    }

    private func generateThumbnail(videoURL: NSURL) -> Promise<UIImage> {
        return Promise { (fulfill, reject) in
            let asset = AVAsset(URL: videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            do {
                let image = try generator.copyCGImageAtTime(asset.duration, actualTime: nil)
                fulfill(UIImage(CGImage: image))
            } catch let error as NSError {
                self.logger.error(error.localizedDescription)
                reject(error)
            }
        }
    }

}

/*
カメラロールに保存する場合はこれらのメソッドを呼ぶ。

*/
extension RecordViewController {

    func saveToPhotos(videoURL: NSURL) {
        UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path!, self, "video:didFinishSavingWithError:contextInfo:", nil)
    }

    func video(videoPath: NSString, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        logger.verbose("videoPath: \(videoPath)")
    }

}