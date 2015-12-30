//
//  RecorderViewController.swift
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

class RecorderViewController: UIViewController {

    @IBOutlet weak var durationLabel: UILabel! {
        didSet {
            durationLabel.hidden = true
        }
    }

    @IBOutlet weak var progressView: UIProgressView! {
        didSet {
            progressView.progress = 0.0
            progressView.hidden = true
        }
    }

    @IBOutlet weak var songView: SongView! {
        didSet {
            songView.hidden = true
        }
    }

    @IBOutlet weak var captureView: GPUImageView!

    @IBOutlet weak var songButton: UIButton! {
        didSet {
            songButton.addTarget(self, action: "songButtonTapped", forControlEvents: .TouchUpInside)
        }
    }

    @IBOutlet weak var recordButton: UIButton! {
        didSet {
            recordButton.addTarget(self, action: "recordButtonTapped", forControlEvents: .TouchUpInside)
            recordButton.enabled = false
        }
    }

    @IBOutlet weak var filterButton: UIButton! {
        didSet {
            filterButton.addTarget(self, action: "filterButtonTapped", forControlEvents: .TouchUpInside)
        }
    }

    let logger = XCGLogger.defaultInstance()

    let camera = Camera.sharedInstance

    var filter: Filterable! {
        didSet {
            if let prevFilter = oldValue {
                prevFilter.removeTarget(captureView)
            }
            filter.addTarget(captureView)
            recorder.filter = filter
        }
    }

    let recorder = Recorder()

    var isRecording: Bool {
        logger.verbose("recordButton.imageView?.image == R.image.recStopButton: \(recordButton.imageView?.image == R.image.recStopButton)")
        return recordButton.imageView?.image == R.image.recStopButton
    }

    var video: Video?
}

// MARK: - View controller
extension RecorderViewController {

    override func viewDidLoad() {
        logger.verbose("")
        super.viewDidLoad()
        // カメラのセットアップ
        filter = filters.first!
        camera.addTarget(filter)
        filter.addTarget(captureView)
        camera.startCapture()
        // レコーダーのセットアップ
        recorder.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        logger.verbose("")
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - Actions & Navigation
extension RecorderViewController {

    func songButtonTapped() {
        logger.verbose("")
        // レコーディング中は無効にする。
        if isRecording {
            return
        }
        performSegueWithIdentifier(R.segue.selectSong, sender: nil)
    }

    func recordButtonTapped() {
        logger.verbose("")
        if isRecording == false {
            CountdownTimer.sharedInstance.showWithSeconds(4.0) { () in
                self.startRecording()
            }
        } else {
            stopRecording()
        }
    }

    func filterButtonTapped() {
        logger.verbose("")
        // レコーディング中は無効にする。
        if isRecording {
            return
        }
        performSegueWithIdentifier(R.segue.selectFilter, sender: nil)
    }

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
            if let artwork = songView.artworkView.image {
                controller.blendImage = artwork
            }
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
extension RecorderViewController {

    func startRecording() {
        logger.verbose("")
        recorder.startRecording(size: captureView.frame.size)
        // ボタンの画像の変更
        recordButton.setImage(R.image.recStopButton, forState: .Normal)
        /*
        // Writerのの作成
        let fileURL = FileIO.sharedInstance.createRecordingFile()
        writer = GPUImageMovieWriter(movieURL: fileURL, size: captureView.frame.size)
        writer.delegate = self
        filter.addTarget(writer)
        // ボタンの画像の変更
        recordButton.setImage(R.image.recOn, forState: .Normal)
        // ビデオの書き込みと音楽の再生と開始
        writer.startRecording()
        audioPlayer.startToPlay()
        */
    }

    func stopRecording() {
        recorder.stopRecording()
    }

}

// MARK: - Recorder Delegate
extension RecorderViewController: RecorderDelegate {
    
    func readyToRecord(item: AVPlayerItem) {
        logger.verbose("")
        durationLabel.text = formatTime(item.duration)
        durationLabel.hidden = false
        progressView.progress = 0.0
        progressView.hidden = false
        recordButton.enabled = true
    }

    func startExporting() {
        HUD.sharedInstance.showLoading()
    }

    func recordingCompleted(video: Video) {
        logger.verbose("")
        recordButton.setImage(R.image.recStartButton, forState: .Normal)
        recorder.prepareToRecord()
        HUD.sharedInstance.dismissLoading()
        self.performSegueWithIdentifier(R.segue.watchVideo, sender: video)
    }

    func recordingFailed(error: NSError) {
        logger.verbose("")
        HUD.sharedInstance.dismissLoading()
        recordButton.setImage(R.image.recStartButton, forState: .Normal)
        recorder.prepareToRecord()
        HUD.sharedInstance.showError(error)
    }

    func playbackTime(time: CMTime, duration: CMTime) {
        // logger.verbose("")
        let remainingTime = CMTimeGetSeconds(duration) - CMTimeGetSeconds(time)
        durationLabel.text = formatTime(CMTimeMakeWithSeconds(remainingTime, Int32(NSEC_PER_SEC)))
        progressView.progress = Float(CMTimeGetSeconds(time)) / Float(CMTimeGetSeconds(duration))
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

// MARK: - Songs view contorller delegate
extension RecorderViewController: SongsViewControllerDelegate {

    func didSelectSong(song: Song) {
        logger.verbose("")
        songView.configure(song)
        recorder.song = song
    }

    func didNotSelectSong() {
        logger.verbose("")
        if let song = recorder.song {
            didSelectSong(song)
        }
        if songView.song == nil {
            songView.hidden = true
        }
    }

}

// MARK: - Filters view controller delegate
extension RecorderViewController: FiltersViewControllerDeleage {

    func didSelectFilter(filter: Filterable) {
        logger.verbose("")
        if self.filter.name == filter.name {
            return
        }
        self.filter = filter
    }

    func didDeselectFilter() {
        logger.verbose("")
        filter.addTarget(captureView)
    }

}
