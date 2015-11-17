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
import Result
import XCGLogger

protocol SongsViewControllerDelegate {
    func didSelectSong(song: Song)
    func didNotSelectSong()
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        Notificator.sharedInstance.dismissLoading()
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
        iTunesAPI.sharedInstance.topsongs().then { [weak self] songs -> () in
            self?.songs = songs
        }.finally {
            Notificator.sharedInstance.dismissLoading()
        }.catch_ { error in
            self.logger.error(error.localizedDescription)
            Notificator.sharedInstance.showError(error)
        }
    }

    func search(keyword: String) {
        Notificator.sharedInstance.showLoading()
        iTunesAPI.sharedInstance.search(keyword: keyword).then { [weak self] songs -> () in
            self?.songs = songs
        }.finally {
            Notificator.sharedInstance.dismissLoading()
        }.catch_ { error in
            self.logger.error(error.localizedDescription)
            Notificator.sharedInstance.showError(error)
        }
    }

}

// MARK: - Actions
extension SongsViewController {

    func checkButtonTapped() {
        if let indexPath = tableView.indexPathForSelectedRow {
            delegate?.didSelectSong(songs[indexPath.row])
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    func closeButtonTapped() {
        delegate?.didNotSelectSong()
        dismissViewControllerAnimated(true, completion: nil)
    }

}

// MARK: - Table view delegate
extension SongsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        guard
            let selectedIndexPath = tableView.indexPathForSelectedRow,
            let cell = tableView.cellForRowAtIndexPath(selectedIndexPath) as? SongTableViewCell else {
            return indexPath
        }
        cell.pauseImageView.hidden = true
        if selectedIndexPath == indexPath {
            if player.isPlaying() {
                player.pause()
            } else {
                player.play()
                cell.pauseImageView.hidden = false
            }
            return nil
        } else {
            return indexPath
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        checkButton.enabled = true
        let song = songs[indexPath.row]
        player.prepareToPlay(song.previewURL)
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
        if let item = player.item, let asset = item.asset as? AVURLAsset {
            if song.previewURL == asset.URL {
                cell.pauseImageView.hidden = false
            }
        }
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
        guard let text = searchBar.text else {
            return
        }
        if text.characters.count < 3 {
            return
        }
        if let controller = childViewControllers.first as? SuggestionsViewController {
            showSuggestionView()
            controller.delegate = self
            controller.keyword = text
        }
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        hideSuggestionView()
        searchBar.resignFirstResponder()
        if let text = searchBar.text {
            search(text)
        }
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else {
            return
        }
        if let controller = childViewControllers.first as? SuggestionsViewController {
            showSuggestionView()
            controller.delegate = self
            controller.keyword = text
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

    func didSelectSuggestion(suggestion: String) {
        logger.verbose("keyword: \(suggestion)")
        searchBar.text = suggestion
        hideSuggestionView()
        searchBar.resignFirstResponder()
        search(suggestion)
    }

}

// MARK: - Audio player delegate
extension SongsViewController: AudioPlayerDelegate {

    func readyToPlay(item: AVPlayerItem) {
        player.startToPlay(item)
        if let indexPath = tableView.indexPathForSelectedRow {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! SongTableViewCell
            cell.pauseImageView.hidden = false
            logger.verbose("indexPath: \(indexPath.row)")
            logger.verbose("cell: \(cell.nameLabel.text)")
        }
    }

    func endTimeToPlay(item: AVPlayerItem) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SongTableViewCell
        cell.pauseImageView.hidden = true
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func playbackTime(time: CMTime, duration: CMTime) {
    }

}

class SongTableViewCell: UITableViewCell {

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var pauseImageView: UIImageView! {
        didSet { pauseImageView.hidden = true }
    }

    func configure(song: Song) {
        artworkImageView.af_setImageWithURL(song.imageURL)
        nameLabel.text = song.name
        artistLabel.text = song.artist
        pauseImageView.hidden = true
    }
    
}
