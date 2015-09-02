//
//  VideoViewController.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/17.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import AVFoundation
import UIKit
import MediaPlayer

import Cartography
import XCGLogger

class VideoViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!

    @IBOutlet weak var slider: UISlider! {
        didSet {
            slider.addTarget(self, action: "beginSeeking:", forControlEvents: .TouchDown)
            slider.addTarget(self, action: "seekPositionChanged:", forControlEvents: .ValueChanged)
            slider.addTarget(self, action: "endSeeking:", forControlEvents: .TouchUpInside | .TouchUpOutside | .TouchCancel)
        }
    }

    @IBOutlet weak var backButton: UIButton! {
        didSet { backButton.addTarget(self, action: "backButtonTapped", forControlEvents: .TouchUpInside) }
    }

    @IBOutlet weak var playButton: UIButton! {
        didSet {
            playButton.enabled = false
            playButton.addTarget(self, action: "playButtonTapped", forControlEvents: .TouchUpInside)
        }
    }

    @IBOutlet weak var actionButton: UIButton! {
        didSet { actionButton.addTarget(self, action: "actionButtonTapped", forControlEvents: .TouchUpInside) }
    }
//    @IBOutlet weak var closeButton: UIButton! {
//        didSet {
//            closeButton.addTarget(self, action: "closeButtonTapped", forControlEvents: .TouchUpInside)
//        }
//    }

    let logger = XCGLogger.defaultInstance()

    let player = VideoPlayer.sharedInstance

    var video: Video!

    override func viewDidLoad() {
        logger.verbose("")
        super.viewDidLoad()

        //if let URL = NSURL(string: video.fileURL) {
        if let URL = FileIO.sharedInstance.videoFileURL(video) {
            player.delegate = self
            player.prepareToPlay(URL)
        }
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
    }

    override func viewWillDisappear(animated: Bool) {
        logger.verbose("")
        super.viewWillDisappear(animated)
        if player.state == .Playing {
            player.pause()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Actions
extension VideoViewController {

    func playButtonTapped() {
        switch player.state {
        case .Playing:
            player.pause()
        default:
            player.play()
        }
    }

    func actionButtonTapped() {
        let message = "\(video.name) - \(video.artist)"
        if let fileURL = FileIO.sharedInstance.videoFileURL(video) {
            //let asset = AVURLAsset(URL: URL, options: nil)
            /*
            if let data = NSData(contentsOfURL: URL) {
                let items = [data]
                let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
                presentViewController(controller, animated: true, completion: nil)
            }
            */
            let controller = UIActivityViewController(activityItems: [message, fileURL], applicationActivities: nil)
            presentViewController(controller, animated: true, completion: nil)
        }
    }

    func closeButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func backButtonTapped() {
        navigationController?.popViewControllerAnimated(true)
    }

    func beginSeeking(sender: UISlider) {
        player.pause()
    }

    func seekPositionChanged(sender: UISlider) {
        player.seekToTime(Double(sender.value))
    }

    func endSeeking(sender: UISlider) {
        player.play()
    }

}

// MARK: - Video player delegate
extension VideoViewController: VideoPlayerDelegate {

    func loadState(state: MPMovieLoadState) {
        switch state {
        case MPMovieLoadState.Playable:
            playButton.enabled = false
        default:
            playButton.enabled = true
        }
    }

    func playbackState(state: MPMoviePlaybackState) {
        switch state {
        case .Playing:
            playButton.setImage(R.image.pause, forState: .Normal)
        default:
            playButton.setImage(R.image.play, forState: .Normal)
        }
    }

    func durationAvailable(duration: Double) {
        slider.minimumValue = 0.0
        slider.maximumValue = Float(duration)
    }

    func readyForDisplay(player: VideoPlayer) {
        videoView.addSubview(player.view)
        player.view.frame = videoView.bounds
        player.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        videoView.addConstraints([
            NSLayoutConstraint(item: player.view, attribute: .Top, relatedBy: .Equal, toItem: videoView, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: player.view, attribute: .Leading, relatedBy: .Equal, toItem: videoView, attribute: .Leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: player.view, attribute: .Bottom, relatedBy: .Equal, toItem: videoView, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: player.view, attribute: .Trailing, relatedBy: .Equal, toItem: videoView, attribute: .Trailing, multiplier: 1, constant: 0),
        ])
        videoView.bringSubviewToFront(backButton)
    }

    func readyToPlay(player: VideoPlayer) {
        playButton.enabled = true
    }

    func playbackTime(time: Double, duration: Double) {
        if isnan(time) {
            return
        }
        if isnan(duration) {
            return
        }
        slider.value = Float(time)
    }

    func endToPlay(player: VideoPlayer) {
    }

}
