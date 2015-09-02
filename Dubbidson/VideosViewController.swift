//
//  VideosViewController.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/18.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

class VideosViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            //tableView.tableFooterView = UIView(frame: CGRectZero)
            tableView.tableFooterView = UIToolbar(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
            tableView.allowsMultipleSelectionDuringEditing = true
        }
    }

    //@IBOutlet weak var toolBar: UIToolbar!

    var videos = [Video]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        setEditing(false, animated: true)
        fetch()
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
        if let toolBar = tableView.tableFooterView as? UIToolbar {
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
        }
        edited = false
    }

    func startEditing() {
        setEditing(true, animated: true)
    }

    func endEditing() {
        if let indexPaths = tableView.indexPathsForSelectedRows() as? [NSIndexPath] {
            let videos = indexPaths.map { (indexPath) -> Video in
                return self.videos[indexPath.row]
            }
            Video.destroy(videos)
            fetch()
        }
        setEditing(false, animated: true)
    }

    func cancelEditing() {
        if edited {
            fetch()
        }
        setEditing(false, animated: true)
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

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!

    func configure(video: Video) {
        if let thumbnailURL = video.thumbnailURL {
            thumbnailImageView.kf_setImageWithURL(thumbnailURL)
        }
        nameLabel.text = video.name
        artistLabel.text = video.artist
        createdAtLabel.text = formatDate(video.createdAt)
    }

    func formatDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        return formatter.stringFromDate(date)
    }
}
