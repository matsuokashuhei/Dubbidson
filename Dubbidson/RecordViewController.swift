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
import RealmSwift
import SVProgressHUD
import XCGLogger

class RecordViewController: UIViewController {

    @IBOutlet weak var captureView: GPUImageView!

    @IBOutlet weak var songView: SongView! {
        didSet {
            songView.delegate = self
        }
    }

    @IBOutlet weak var recordButton: UIButton! {
        didSet { recordButton.enabled = false }
    }

    @IBOutlet weak var filterButton: UIButton! {
        didSet { filterButton.addTarget(self, action: "filterButtonTapped", forControlEvents: .TouchUpInside) }
    }

    let logger = XCGLogger.defaultInstance()

    let camera = Camera.sharedInstance

    var filterOperator: FilterOperator! {
        didSet {
            if let oldValue = oldValue {
                camera.removeTarget(oldValue.filter as! GPUImageInput)
                oldValue.filter.removeTarget(captureView)
            }
        }
    }

    var squareFilter: GPUImageCropFilter!

    var writer: GPUImageMovieWriter!

    let audioPlayer = AudioPlayer.sharedInstance

}

// MARK: - View controller
extension RecordViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // カメラのセットアップ
        filterOperator = filterOperators.first!
        camera.addTarget(filterOperator.filter as! GPUImageInput)
        filterOperator.filter.addTarget(captureView)
        camera.startCapture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - ビデオの保存
extension RecordViewController {

    func startRecording() {
        // Writerのの作成
        let fileURL = FileManager.videoFileURL()
        writer = GPUImageMovieWriter(movieURL: fileURL, size: CGSize(width: captureView.frame.size.width, height: captureView.frame.size.width))
        writer.delegate = self

        // 書き込むフィルターの作成
        squareFilter = GPUImageCropFilter(cropRegion: CGRect(x: 0.0, y: 0.125, width: 1.0, height: 0.75))
        filterOperator.filter.addTarget(squareFilter)
        squareFilter.addTarget(writer)

        // ボタンの画像の変更
        recordButton.setImage(UIImage(named: "ic_lens_48px"), forState: .Normal)
        // ビデオの書き込みと音楽の再生と開始
        writer.startRecording()
        audioPlayer.play()
    }

    func finishRecording() {
        // Writeの終了
        writer.finishRecording()
        // 書き込むフィルターの終了
        squareFilter.removeTarget(writer)
        // ボタンの画像の変更
        recordButton.setImage(UIImage(named: "ic_panorama_fish_eye_48px"), forState: .Normal)
    }

}

// MARK: - Actions
extension RecordViewController {

    func recordButtonTapped() {
        startRecording()
    }

    func filterButtonTapped() {
        performSegueWithIdentifier("selectFilter", sender: nil)
    }

}

// MARK: - Navigation
extension RecordViewController {

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectSong" {
            let controller = segue.destinationViewController as! SongsViewController
            controller.delegate = self
        }
        if segue.identifier == "selectFilter" {
            let controller = segue.destinationViewController as! FiltersViewController
            controller.filterOperator = filterOperator
            controller.artworkImage = songView.artworkImage
            controller.delegate = self
        }
        if segue.identifier == "watchVideo" {
            let controller = segue.destinationViewController as! AVPlayerViewController
            controller.player = AVPlayer(URL: sender as! NSURL)
        }
    }

}

// MARK: - Song view delegate
extension RecordViewController: SongViewDelegate {

    func songViewTapped() {
        performSegueWithIdentifier("selectSong", sender: nil)
    }

}

// MARK: - Songs view contorller delegate
extension RecordViewController: SongsViewControllerDelegate {

    func selectedSong(song: Song) {
        songView.song = song
        Downloader.sharedInstance.download(song) { (result) -> () in
            switch result {
            case .Success(let box):
                let audioURL = box.value
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
        recordButton.addTarget(self, action: "recordButtonTapped", forControlEvents: .TouchUpInside)
        recordButton.enabled = true
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay(audioURL)
    }

}

// MARK: - Audio player delegate
extension RecordViewController: AudioPlayerDelegate {

    func readyToPlay(item: AVPlayerItem) {
    }

    func endTimeToPlay(item: AVPlayerItem) {
        finishRecording()
    }

    func playAtTime(item: AVPlayerItem) {
    }
    
}

// MARK: - Filters view controller delegate
extension RecordViewController: FiltersViewControllerDeleage {

    func selectFilter(filterOperator: FilterOperator) {
        if self.filterOperator.name != filterOperator.name {
            self.filterOperator = filterOperator
            filterOperator.filter.addTarget(captureView)
        }
    }

}

// MARK: - GPU image movie writer delegate
extension RecordViewController: GPUImageMovieWriterDelegate {

    func movieRecordingCompleted() {
        logger.verbose("")
        let song = songView.song
        if let videoURL = writer.assetWriter.outputURL {
            if let audioURL = FileManager.audioFileURL(song) {
                SVProgressHUD.show()
                Mixer.sharedInstance.mixdown(videoURL: videoURL, audioURL: audioURL) { (result) -> () in
                    Async.main {
                        SVProgressHUD.dismiss()
                    }
                    switch result {
                    case .Success(let box):
                        Async.main {
                            let fileURL = box.value
                            Video.create(song, fileURL: fileURL)
                            self.performSegueWithIdentifier("watchVideo", sender: fileURL)
                        }
                    case .Failure(let box):
                        let error = box.value
                        self.logger.error(error.localizedDescription)
                        Async.main {
                            SVProgressHUD.showErrorWithStatus(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }

    func movieRecordingFailedWithError(error: NSError!) {
        logger.error("error: \(error.localizedDescription)")
        SVProgressHUD.showErrorWithStatus(error.localizedDescription)
    }

}