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
    func playbackTime(time: CMTime, duration: CMTime)
}

private var KVOContext = 0

class AudioPlayer: NSObject {

    static let sharedInstance = AudioPlayer()

    let logger = XCGLogger.defaultInstance()

    var player: AVPlayer! {
        didSet {
            player.addObserver(self, forKeyPath: "status", options: .Initial | .New, context: &KVOContext)
            player.addObserver(self, forKeyPath: "rate", options: .Initial | .New, context: &KVOContext)
        }
    }

    var item: AVPlayerItem! {
        didSet {
            let keyPaths = ["status", "duration"]
            if let prevItem = oldValue {
                for keyPath in keyPaths {
                    prevItem.removeObserver(self, forKeyPath: keyPath, context: &KVOContext)
                }
                if let periodicTimeObserver: AnyObject = self.periodicTimeObserver {
                    player.removeTimeObserver(periodicTimeObserver)
                }
            }
            for keyPath in keyPaths {
                item.addObserver(self, forKeyPath: keyPath, options: .Initial | .New, context: &KVOContext)
            }
        }
    }

    var periodicTimeObserver: AnyObject?

    var delegate: AudioPlayerDelegate?

    /**
    音楽を再生する準備をする。
    
    :param: URL 再生する音楽のURL
    */
    func prepareToPlay(URL: NSURL) {
        logger.debug("URL: \(URL)")
        item = AVPlayerItem(URL: URL)
        if let player = self.player {
            player.replaceCurrentItemWithPlayerItem(item)
        } else {
            self.player = AVPlayer(playerItem: item)
        }
    }

    private func readyToPlay(item: AVPlayerItem) {
        delegate?.readyToPlay(item)
    }

    func startToPlay(item: AVPlayerItem) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemDidPlayToEndTime:", name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
        player.play()
        let second = CMTimeMakeWithSeconds(0.1, 60)
        periodicTimeObserver = player.addPeriodicTimeObserverForInterval(second, queue: nil) { [weak self] (time: CMTime) in
            self?.playbackTime(item)
        }
    }

    func startToPlay() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemDidPlayToEndTime:", name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
        player.play()
        let second = CMTimeMakeWithSeconds(0.1, 60)
        periodicTimeObserver = player.addPeriodicTimeObserverForInterval(second, queue: nil) { [weak self] (time: CMTime) in
            self?.playbackTime(item)
        }
    }

    func play() {
        if let item = player.currentItem {
            player.play()
        }
    }

    func pause() {
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
        if context != &KVOContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        if let player = object as? AVPlayer {
            if keyPath == "status" {
                switch player.status {
                case .ReadyToPlay:
                    logger.verbose("player.status: ReadyToPlay")
                case .Failed:
                    logger.verbose("player.status: Failed")
                    // TODO:
                    break
                case .Unknown:
                    logger.verbose("player.status: Unknown")
                    // TODO:
                    break
                }
                return
            }
            if keyPath == "rate" {
                logger.verbose("rate: \(player.rate)")
            }
        }
        if let item = object as? AVPlayerItem {
            if keyPath == "status" {
                switch item.status {
                case .ReadyToPlay:
                    logger.verbose("item.status: ReadyToPlay")
                    if let item = player.currentItem {
                        readyToPlay(item)
                    }
                case .Failed:
                    logger.verbose("item.status: Failed")
                    break
                case .Unknown:
                    logger.verbose("item.status: Unknown")
                    break
                }
                return
            }
            if keyPath == "duration" {
                // TODO: 使っていないので消す。
                let duration: CMTime
                if let value = change[NSKeyValueChangeNewKey] as? NSValue {
                    duration = value.CMTimeValue
                } else {
                    duration = kCMTimeZero
                }
            }
        }
    }

    func playbackTime(item: AVPlayerItem) {
        delegate?.playbackTime(item.currentTime(), duration: item.duration)
    }

    func itemDidPlayToEndTime(notification: NSNotification) {
        if let item = notification.object as? AVPlayerItem {
            logger.debug("")
            //player.removeTimeObserver(periodicTimeObserver)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
            delegate?.endTimeToPlay(item)
            player.seekToTime(kCMTimeZero)
        }
    }
    
}
