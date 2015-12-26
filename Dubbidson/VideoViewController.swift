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

    @IBOutlet weak var songView: SongView! {
        didSet {
            guard let song = video.song else {
                return
            }
            songView.artworkView.af_setImageWithURL(song.artworkURL)
            songView.nameLabel.text = song.name
            songView.artistLabel.text = song.artist
        }
    }

    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.addTarget(self, action: "backButtonTapped", forControlEvents: .TouchUpInside)
        }
    }

    @IBOutlet weak var recordButton: UIButton! {
        didSet {
            recordButton.addTarget(self, action: "recordButtonTapped", forControlEvents: .TouchUpInside)
        }
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

    let logger = XCGLogger.defaultInstance()

    let player = VideoPlayer.sharedInstance

    var video: Video!

    override func viewDidLoad() {
        logger.verbose("")
        super.viewDidLoad()
        if let fileURL = video.fileURL {
            player.delegate = self
            player.prepareToPlay(fileURL)
        }
    }

    override func viewWillAppear(animated: Bool) {
        logger.verbose("")
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(animated: Bool) {
        logger.verbose("")
        super.viewWillDisappear(animated)
        if player.state == .Playing {
            player.pause()
        }
    }

    override func viewDidDisappear(animated: Bool) {
        logger.verbose("")
        super.viewDidDisappear(animated)
        //navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK: - Actions
extension VideoViewController {

    func recordButtonTapped() {
        logger.verbose("tabBarController?.selectedIndex: \(tabBarController?.selectedIndex)")
        guard let selectedIndex = tabBarController?.selectedIndex else {
            return
        }
        if selectedIndex == 0 {
            backButtonTapped()
            return
        }
        if let viewControllers = tabBarController?.viewControllers {
            if let viewController = viewControllers.first as? UINavigationController {
                for childViewController in viewController.childViewControllers {
                    if let recorderViewController = childViewController as? RecorderViewController {
                        recorderViewController.didSelectSong(video.song!)
                    }
                }
            }
        }
        tabBarController?.selectedIndex = 0
    }

    func playButtonTapped() {
        switch player.state {
        case .Playing:
            player.pause()
        default:
            player.play()
        }
    }

    func actionButtonTapped() {
        guard
            let song = video.song,
            let fileURL = video.fileURL else {
            return
        }
        let message = "\(song.name) - \(song.artist)"
        let controller = UIActivityViewController(activityItems: [message, fileURL], applicationActivities: nil)
        controller.completionWithItemsHandler = { (activityType, completed, info, error) in
            if let error = error {
                self.logger.error(error.description)
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case R.segue.recordVideo:
            let controller = segue.destinationViewController as! RecorderViewController
            controller.video = video
        default:
            super.prepareForSegue(segue, sender: sender)
        }
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
            playButton.setImage(R.image.pauseButton, forState: .Normal)
        default:
            playButton.setImage(R.image.playButton, forState: .Normal)
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

