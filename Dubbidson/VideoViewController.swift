//
//  VideoViewController.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/17.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import MediaPlayer

import Cartography
import XCGLogger

class VideoViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!

    @IBOutlet weak var playButton: UIButton! {
        didSet {
            playButton.enabled = false
            playButton.addTarget(self, action: "playButtonTapped", forControlEvents: .TouchUpInside)
        }
    }

    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.addTarget(self, action: "closeButtonTapped", forControlEvents: .TouchUpInside)
        }
    }

    let logger = XCGLogger.defaultInstance()

    let player = VideoPlayer.sharedInstance

    var video: Video!

    override func viewDidLoad() {
        logger.verbose("")
        super.viewDidLoad()

        //if let URL = NSURL(string: video.fileURL) {
        if let URL = FileIO.sharedInstace.videoFileURL(video) {
            player.delegate = self
            player.prepareToPlay(URL)
        }
        // Do any additional setup after loading the view.
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

    func closeButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
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

    func duration(player: VideoPlayer) {
    }

    func readyForDisplay(player: VideoPlayer) {
        videoView.addSubview(player.view)
        player.view.frame = videoView.bounds
        //player.view.contentMode = UIViewContentMode.ScaleAspectFit
        player.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        /*
        layout(videoView, player.view) { (view1, view2) in
            view1.width == view2.width
            view1.height == view2.height
            view1.top == view2.top
            view1.left == view2.left
        }
        */
        videoView.addConstraints([
            NSLayoutConstraint(item: player.view, attribute: .Top, relatedBy: .Equal, toItem: videoView, attribute: .Top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: player.view, attribute: .Leading, relatedBy: .Equal, toItem: videoView, attribute: .Leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: player.view, attribute: .Bottom, relatedBy: .Equal, toItem: videoView, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: player.view, attribute: .Trailing, relatedBy: .Equal, toItem: videoView, attribute: .Trailing, multiplier: 1, constant: 0),
        ])
    }

    func readyToPlay(player: VideoPlayer) {
        playButton.enabled = true
        /*
        show(closeButton)
        show(playButton)
        */
    }

    func endToPlay(player: VideoPlayer) {
    }

}