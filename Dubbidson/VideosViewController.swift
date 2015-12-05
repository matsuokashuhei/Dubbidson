//
//  VideosViewController.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/18.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import XCGLogger

class VideosViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIToolbar(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
            tableView.allowsMultipleSelectionDuringEditing = true
        }
    }

    var videos = [Video]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showBanner:", name: BannerViewShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideBanner:", name: BannerViewHideNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        setEditing(false, animated: true)
        fetch()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case R.segue.watchVideo:
                let controller = segue.destinationViewController as! VideoViewController
                controller.video = sender as! Video
            default:
                super.prepareForSegue(segue, sender: sender)
            }
        }
    }

    var edited = false

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        guard let toolBar = tableView.tableFooterView as? UIToolbar else {
            return
        }
        tableView.setEditing(editing, animated: animated)
        if editing {
            let cancel = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelEditing")
            let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let trash = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "endEditing")
            toolBar.setItems([cancel, space, trash], animated: true)
        } else {
            let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let edit = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "startEditing")
            toolBar.setItems([space, edit], animated: true)
        }
        edited = false
    }

    func startEditing() {
        setEditing(true, animated: true)
    }

    func endEditing() {
        tableView.indexPathsForSelectedRows?.map { (indexPath) -> Video in
            return self.videos[indexPath.row]
        }.forEach { (video) -> () in
            DB.sharedInstance.delete(video)
        }
        fetch()
        setEditing(false, animated: true)
    }

    func cancelEditing() {
        if edited {
            fetch()
        }
        setEditing(false, animated: true)
    }

    func showBanner(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(notification)
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 20.0, right: 0.0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 20.0, right: 0.0)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    func hideBanner(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(notification)
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 50.0, right: 0.0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 50.0, right: 0.0)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

// MARK: - DB
extension VideosViewController {

    func fetch() {
        videos = Video.all()
    }

}

// MARK: - Table view delegate
extension VideosViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        logger.verbose("")
        if tableView.editing {
            return
        } else {
            let video = videos[indexPath.row]
            performSegueWithIdentifier(R.segue.watchVideo, sender: video)
        }
    }

}

// MARK: - Table view data source
extension VideosViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let video = videos[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.videoTableViewCell, forIndexPath: indexPath)!
        cell.configure(video)
        return cell
    }

}

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var artworkView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!

    func configure(video: Video) {
        guard let song = video.song else {
            return
        }
        thumbnailView.image = video.thumbnail
        nameLabel.text = song.name
        artistLabel.text = song.artist
        artworkView.af_setImageWithURL(song.artworkURL)
        createdLabel.text = formatDate(video.created)
    }

    func formatDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        return formatter.stringFromDate(date)
    }
}
