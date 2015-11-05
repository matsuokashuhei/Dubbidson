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

import XCGLogger

class VideoViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!

    @IBOutlet weak var slider: UISlider! {
        didSet {
            slider.addTarget(self, action: "beginSeeking:", forControlEvents: .TouchDown)
            slider.addTarget(self, action: "seekPositionChanged:", forControlEvents: .ValueChanged)
            slider.addTarget(self, action: "endSeeking:", forControlEvents: [.TouchUpInside, .TouchUpOutside, .TouchCancel])
        }
    }

    @IBOutlet weak var songNameLabel: UILabel!

    @IBOutlet weak var songArtistLabel: UILabel!

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

    let logger: XCGLogger = {
        let logger = XCGLogger.defaultInstance()
        logger.setup(.Info, showLogIdentifier: true, showFunctionName: true, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: nil, fileLogLevel: nil)
        return logger
    }()

    let player = VideoPlayer.sharedInstance

    var video: Video!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let fileURL = video.fileURL {
            player.delegate = self
            player.prepareToPlay(fileURL)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if player.state == .Playing {
            player.pause()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
        guard let fileURL = video.fileURL else {
            return
        }
        let controller = UIActivityViewController(activityItems: [message, fileURL], applicationActivities: nil)
        controller.completionWithItemsHandler = { (activityType, completed, info, error) in
            if let error = error {
                self.logger.error(error.localizedDescription)
                return
            }
            if completed {
                if let activityType = activityType {
                    switch activityType {
                    case UIActivityTypePostToFacebook:
                        self.logger.verbose("Post to Facebook")
                    case UIActivityTypePostToTwitter:
                        self.logger.verbose("Post to Twitter")
                    case UIActivityTypePostToWeibo:
                        self.logger.verbose("Post to Weibo")
                    case UIActivityTypeMessage:
                        self.logger.verbose("Message")
                    case UIActivityTypeMail:
                        self.logger.verbose("Mail")
                    case UIActivityTypePostToVimeo:
                        self.logger.verbose("Vimeo")
                    case UIActivityTypePostToTencentWeibo:
                        self.logger.verbose("Post to Tencent Weibo")
                    default:
                        self.logger.verbose("Others")
                    }
                }
            }
            if let info = info {
                self.logger.verbose("info: \(info)")
            }
        }
        presentViewController(controller, animated: true, completion: nil)
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
        videoView.bringSubviewToFront(backButton)
        /*
        player.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        videoView.addConstraints([
            NSLayoutConstraint(item: player.view, attribute: .Top, relatedBy: .Equal, toItem: videoView, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: player.view, attribute: .Leading, relatedBy: .Equal, toItem: videoView, attribute: .Leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: player.view, attribute: .Bottom, relatedBy: .Equal, toItem: videoView, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: player.view, attribute: .Trailing, relatedBy: .Equal, toItem: videoView, attribute: .Trailing, multiplier: 1, constant: 0),
        ])
        layout(videoView, player.view) { view1, view2 in
            view1.top == view2.top
            view1.left == view2.left
            view1.width == view2.width
            view1.height == view2.height
        }
        */
    }

    func readyToPlay(player: VideoPlayer) {
        playButton.enabled = true
        songNameLabel.text = video.name
        songArtistLabel.text = video.artist
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
