//
//  MoviePlayer.swift
//  AirV
//
//  Created by matsuosh on 2015/07/24.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation
import MediaPlayer

import XCGLogger

protocol VideoPlayerDelegate {
    func loadState(state: MPMovieLoadState)
    func playbackState(state: MPMoviePlaybackState)
    func durationAvailable(duration: Double)
    func readyForDisplay(player: VideoPlayer)
    func readyToPlay(player: VideoPlayer)
    func playbackTime(time: Double, duration: Double)
    func endToPlay(player: VideoPlayer)
}

class VideoPlayer: NSObject {

    //let logger = XCGLogger.defaultInstance()
    let logger: XCGLogger = {
        let logger = XCGLogger.defaultInstance()
        logger.setup(.Info, showLogIdentifier: true, showFunctionName: true, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: nil, fileLogLevel: nil)
        return logger
    }()

    static let sharedInstance = VideoPlayer()

    private let player: MPMoviePlayerController

    var delegate: VideoPlayerDelegate?

    var view: UIView {
        return player.view
    }

    var state: MPMoviePlaybackState {
        return player.playbackState
    }

    override init() {
        logger.verbose("")
        player = MPMoviePlayerController()
        player.controlStyle = .None
        player.shouldAutoplay = false
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadStateDidChange:", name: MPMoviePlayerLoadStateDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playBackStateDidChange:", name: MPMoviePlayerPlaybackStateDidChangeNotification, object: nil)
    }

    func prepareToPlay(URL: NSURL) {
        logger.debug("URL: \(URL)")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "durationAvailable:", name: MPMovieDurationAvailableNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "readyForDisplay:", name: MPMoviePlayerReadyForDisplayDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mediaIsPreparedToPlayDidChange:", name: MPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: nil)
        player.contentURL = URL
        player.prepareToPlay()
    }

    func play() {
        player.play()
        Timer.start(target: self, selector: "playbackTime")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playbackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
    }

    func pause() {
        player.pause()
    }

    func stop() {
        player.stop()
    }

    func seekToTime(seconds: Double) {
        player.currentPlaybackTime = seconds
    }

}

extension VideoPlayer {

    func loadStateDidChange(notification: NSNotification) {
        switch player.loadState {
        case MPMovieLoadState.Unknown:
            logger.verbose("Unknown")
        case MPMovieLoadState.Playable:
            logger.verbose("Playable")
        case MPMovieLoadState.PlaythroughOK:
            logger.verbose("PlaythroughOK")
        case MPMovieLoadState.Stalled:
            logger.verbose("Stalled")
        default:
            logger.verbose("?")
        }
        delegate?.loadState(player.loadState)
    }

    func playBackStateDidChange(notification: NSNotification) {
        switch player.playbackState {
        case .Stopped:
            logger.verbose("Stopped")
        case .Playing:
            logger.verbose("Playing")
        case .Paused:
            logger.verbose("Paused")
        case .Interrupted:
            logger.verbose("Interrupted")
        case .SeekingForward:
            logger.verbose("SeekingForward")
        case .SeekingBackward:
            logger.verbose("SeekingBackward")
        }
        delegate?.playbackState(player.playbackState)
    }

    func durationAvailable(notification: NSNotification) {
        logger.verbose("")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMovieDurationAvailableNotification, object: nil)
        delegate?.durationAvailable(player.duration)
    }

    func readyForDisplay(notification: NSNotification) {
        logger.verbose("")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerReadyForDisplayDidChangeNotification, object: nil)
        delegate?.readyForDisplay(self)
    }

    func mediaIsPreparedToPlayDidChange(notification: NSNotification) {
        logger.verbose("")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMediaPlaybackIsPreparedToPlayDidChangeNotification, object: nil)
        delegate?.readyToPlay(self)
    }

    func playbackTime() {
        delegate?.playbackTime(player.currentPlaybackTime, duration: player.duration)
    }

    func playbackDidFinish(notification: NSNotification) {
        logger.verbose("")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
        delegate?.endToPlay(self)
    }

}

class Timer {

    class func start(target target: AnyObject, selector: Selector) {
        sharedInstance.start(target: target, selector: selector)
    }

    class func stop() {
        sharedInstance.stop()
    }

    var timer: NSTimer? {
        willSet {
            stop()
        }
    }

    static var sharedInstance = Timer()

    func start(target target: AnyObject, selector: Selector) {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: target, selector: selector, userInfo: nil, repeats: true)
    }

    func stop() {
        if let timer = timer {
            timer.invalidate()
        }
    }

}