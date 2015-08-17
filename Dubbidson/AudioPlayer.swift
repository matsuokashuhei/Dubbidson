//
//  AudioPlayer.swift
//  Dubski
//
//  Created by matsuosh on 2015/08/16.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation
import AVFoundation

import Alamofire
import Box
import Result
import XCGLogger

protocol AudioPlayerDelegate {
    func readyToPlay(item: AVPlayerItem)
    func endTimeToPlay(item: AVPlayerItem)
    func playAtTime(item: AVPlayerItem)
}

class AudioPlayer: NSObject {

    let logger = XCGLogger.defaultInstance()

    static let sharedInstance = AudioPlayer()

    var player: AVPlayer!
    var periodicTimeObserver: AnyObject?

    var delegate: AudioPlayerDelegate?

    var song: Song!

    func prepareToPlay(song: Song) {
        self.song = song
        prepareToPlay(song.previewURL)
    }

    func prepareToPlay(URL: NSURL) {
        logger.debug("URL: \(URL)")
        let item = AVPlayerItem(URL: URL)
        if let player = self.player {
            player.currentItem.removeObserver(self, forKeyPath: "status")
            player.removeObserver(self, forKeyPath: "status")
            player.replaceCurrentItemWithPlayerItem(item)
        } else {
            self.player = AVPlayer(playerItem: item)
        }
        player.addObserver(self, forKeyPath: "status", options: .Initial | .New, context: nil)
        item.addObserver(self, forKeyPath: "status", options: .Initial | .New, context: nil)
    }

    func readyToPlay(item: AVPlayerItem) {
        logger.verbose("delegate.readyToPlay(item)")
        delegate?.readyToPlay(item)
        startToPlay(item)
    }

    func startToPlay(item: AVPlayerItem) {
        let second = CMTimeMakeWithSeconds(1, Int32(NSEC_PER_SEC))
        periodicTimeObserver = player.addPeriodicTimeObserverForInterval(second, queue: nil) { (time: CMTime) in
            self.playAtTime(item)
        }
    }

    func play() {
        if let item = player.currentItem {
            player.play()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemDidPlayToEndTime:", name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
        }
    }

    func pause() {
        //player.rate = 0.0
        if let player = self.player {
            player.pause()
        }
    }

    func isPlaying() -> Bool {
        if let player = self.player {
            return player.rate > 0.0
        } else {
            return false
        }
    }
}

// MARK: - KVO
extension AudioPlayer {

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if let player = object as? AVPlayer {
            if keyPath == "status" {
                switch player.status {
                case .ReadyToPlay:
                    self.logger.verbose("")
                    if let item = player.currentItem {
                        readyToPlay(item)
                    }
                case .Failed:
                    // TODO:
                    break
                case .Unknown:
                    // TODO:
                    break
                }
                return
            }
        }
        if let item = object as? AVPlayerItem {
            if keyPath == "status" {
                switch item.status {
                case .ReadyToPlay:
                    self.logger.verbose("")
                case .Failed:
                    break
                case .Unknown:
                    break
                }
                return
            }
        }
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }

    func playAtTime(item: AVPlayerItem) {
        delegate?.playAtTime(item)
    }

    func itemDidPlayToEndTime(notification: NSNotification) {
        if let item = notification.object as? AVPlayerItem {
            logger.debug("")
            player.removeTimeObserver(periodicTimeObserver)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
            player.seekToTime(kCMTimeZero)
            delegate?.endTimeToPlay(item)
        }
    }
    
}
