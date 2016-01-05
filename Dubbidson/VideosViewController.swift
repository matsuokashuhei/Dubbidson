//
//  VideosViewController.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/12/16.
//  Copyright © 2015年 matsuosh. All rights reserved.
//

import UIKit

import XCGLogger

class VideosViewController: UIViewController {
    
    let logger = XCGLogger.defaultInstance()
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.allowsMultipleSelection = true
        }
    }

    @IBOutlet weak var toolbar: UIToolbar! {
        didSet {
        }
    }

    var videos = [Video]() {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "showBanner:", name: BannerViewShowNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideBanner:", name: BannerViewHideNotification, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        setEditing(false, animated: true)
        fetch()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            let cancel = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelEditing")
            let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let trash = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "finishEditing")
            toolbar.setItems([cancel, space, trash], animated: true)
        } else {
            let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let edit = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "startEditing")
            toolbar.setItems([space, edit], animated: true)
        }
    }

    func startEditing() {
        setEditing(true, animated: true)
    }

    func finishEditing() {
        guard let items = collectionView.indexPathsForSelectedItems() where items.count > 0 else {
            setEditing(false, animated: true)
            return
        }
        let controller: UIAlertController = {
            let controller = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            controller.addAction(
                UIAlertAction(title: "Delete \(items.count == 1 ? "Video" : "Videos")", style: .Default) { _ in
                    HUD.sharedInstance.showLoading()
                    items.forEach({ (indexPath) -> () in
                        // TODO: エラー処理
                        self.videos[indexPath.row].delete()
                    })
                    HUD.sharedInstance.dismissLoading()
                    self.fetch()
                    self.setEditing(false, animated: true)
                })
            controller.addAction(
                UIAlertAction(title: "Cancel", style: .Cancel) { _ in
                    self.fetch()
                    self.setEditing(false, animated: true)
                })
            return controller
        }()
        presentViewController(controller, animated: true, completion: nil)
    }

    func cancelEditing() {
        fetch()
        setEditing(false, animated: true)
    }

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

extension VideosViewController {

    func fetch() {
        HUD.sharedInstance.showLoading()
        videos = Video.all()
        HUD.sharedInstance.dismissLoading()
    }

}

extension VideosViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(R.reuseIdentifier.videoViewCell, forIndexPath: indexPath)!
        cell.configure(videos[indexPath.row])
        cell.backgroundView = {
            let view = UIView(frame: cell.bounds)
            view.backgroundColor = UIColor.clearColor()
            return view
        }()
        cell.selectedBackgroundView = {
            let view = UIView(frame: cell.bounds)
            view.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.3)
            return view
        }()
        return cell
    }

}

extension VideosViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        logger.verbose("indexPath.row: \(indexPath.row)")
        if editing {
            return
        } else {
            performSegueWithIdentifier(R.segue.watchVideo, sender: videos[indexPath.row])
        }
    }

}

extension VideosViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = UIScreen.mainScreen().bounds.width / 2 - 2
        let height = 8 + (width - 16) + 8 + (width - 16) * 0.25
        logger.verbose("UIScreen.mainScreen().bounds.width: \(UIScreen.mainScreen().bounds.width), width: \(width), height: \(height)")
        return CGSize(width: width, height: height)
    }

}

class VideoViewCell: UICollectionViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var artworkView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    //@IBOutlet weak var createdLabel: UILabel!

    func configure(video: Video) {
        guard let song = video.song else {
            return
        }
        thumbnailView.image = video.thumbnail
        nameLabel.text = song.name
        artistLabel.text = song.artist
        artworkView.af_setImageWithURL(song.artworkURL)
        //createdLabel.text = formatDate(video.created)
    }

    func formatDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        return formatter.stringFromDate(date)
    }

}