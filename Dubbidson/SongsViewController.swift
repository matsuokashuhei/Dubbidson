//
//  SongsViewController.swift
//  Dubski
//
//  Created by matsuosh on 2015/08/16.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

import AVFoundation
import UIKit

import Async
import Box
import Kingfisher
import Result
import XCGLogger

protocol SongsViewControllerDelegate {
    func selectedSong(song: Song)
}

class SongsViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar! {
        didSet { searchBar.delegate = self }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 64.0, right: 0.0)
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 64.0, right: 0.0)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView(frame: CGRectZero)
        }
    }

    @IBOutlet weak var suggestionsView: UIView! {
        didSet { suggestionsView.hidden = true }
    }

    @IBOutlet weak var closeButton: UIButton! {
        didSet { closeButton.addTarget(self, action: "closeButtonTapped", forControlEvents: .TouchUpInside) }
    }

    @IBOutlet weak var checkButton: UIButton! {
        didSet {
            checkButton.addTarget(self, action: "checkButtonTapped", forControlEvents: .TouchUpInside)
            checkButton.enabled = false
        }
    }

    let logger = XCGLogger.defaultInstance()

    var delegate: SongsViewControllerDelegate?

    let player = AudioPlayer.sharedInstance

    var songs = [Song]() {
        didSet {
            tableView.reloadData()
            tableView.contentOffset = CGPointMake(0, 0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        player.delegate = self
        fetch()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - iTunes search
extension SongsViewController {

    func fetch() {
        Notificator.sharedInstance.showLoading()
        iTunesAPI.sharedInstance.topsongs().then { songs -> () in
            self.songs = songs
        }.finally {
            Notificator.sharedInstance.dismissLoading()
        }.catch { error in
            self.logger.error(error.localizedDescription)
        }
    }

    func search(keyword: String) {
        Notificator.sharedInstance.showLoading()
        iTunesAPI.sharedInstance.search(keyword: keyword).then { songs -> () in
            self.songs = songs
        }.finally {
            Notificator.sharedInstance.dismissLoading()
        }.catch { error in
            self.logger.error(error.localizedDescription)
        }
    }

}

// MARK: - Actions
extension SongsViewController {

    func checkButtonTapped() {
        if let indexPath = tableView.indexPathForSelectedRow() {
            player.delegate = nil
            delegate?.selectedSong(songs[indexPath.row])
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    func closeButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

// MARK: - Table view delegate
extension SongsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        checkButton.enabled = true
        //let cell = tableView.dequeueReusableCellWithIdentifier("SongTableViewCell", forIndexPath: indexPath) as! SongTableViewCell
        let song = songs[indexPath.row]
        if player.isPlaying() {
            if let nowPlaying = player.song {
                if nowPlaying.id == song.id {
                    player.pause()
                    //cell.pauseImage.hidden = true
                    return
                }
            }
        }
        //cell.pauseImage.hidden = false
        player.prepareToPlay(song)
    }

}

// MARK: - Table view data source
extension SongsViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let song = songs[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.songTableViewCell, forIndexPath: indexPath)!
        cell.configure(song)
        return cell
    }

}

// MARK: - Scroll view delegate
extension SongsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }

}

// MARK: - Search bar delegate
extension SongsViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        let text = searchBar.text
        if text.isEmpty {
            return
        }
        if let controller = childViewControllers.first as? SuggestionsViewController {
            showSuggestionView()
            controller.delegate = self
            controller.keyword = searchBar.text
        }
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        hideSuggestionView()
        searchBar.resignFirstResponder()
        search(searchBar.text)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text.isEmpty {
            return
        }
        if let controller = childViewControllers.first as? SuggestionsViewController {
            showSuggestionView()
            controller.delegate = self
            controller.keyword = searchBar.text
        }
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        hideSuggestionView()
        searchBar.resignFirstResponder()
    }

    func showSuggestionView() {
        suggestionsView.hidden = false
        view.bringSubviewToFront(self.suggestionsView)
    }

    func hideSuggestionView() {
        suggestionsView.hidden = true
        view.sendSubviewToBack(suggestionsView)
    }

}

// MARK: - Suggestions view controller delegate
extension SongsViewController: SuggestionsViewControllerDelegate {

    func didSelectKeyword(keyword: String) {
        logger.verbose("keyword: \(keyword)")
        searchBar.text = keyword
        hideSuggestionView()
        searchBar.resignFirstResponder()
        search(keyword)
    }

}

// MARK: - Audio player delegate
extension SongsViewController: AudioPlayerDelegate {

    func readyToPlay(item: AVPlayerItem) {
        player.play()
    }

    func endTimeToPlay(item: AVPlayerItem) {
    }

    func playbackTime(time: CMTime, duration: CMTime) {
    }

}

class SongTableViewCell: UITableViewCell {

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
//    @IBOutlet weak var pauseImage: UIImageView! {
//        didSet {
//            pauseImage.hidden = true
//        }
//    }

    func configure(song: Song) {
        artworkImageView.kf_setImageWithURL(song.imageURL)
        nameLabel.text = song.name
        artistLabel.text = song.artist
//        pauseImage.hidden = true
    }
}
