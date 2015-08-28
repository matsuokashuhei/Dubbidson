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
        }
    }

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
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        //navigationController?.navigationBarHidden = true
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
        let video = videos[indexPath.row]
        performSegueWithIdentifier(R.segue.watchVideo, sender: video)
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
        thumbnailImageView.kf_setImageWithURL(FileIO.sharedInstance.thumbnailURL(video)!)
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
