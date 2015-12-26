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
        navigationController?.setNavigationBarHidden(false, animated: false)
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
            navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelEditing"), animated: true)
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "startEditing"), animated: true)
        }
    }

    func startEditing() {
        setEditing(true, animated: true)
    }

    func finishEditing() {
        HUD.sharedInstance.showLoading()
        collectionView.indexPathsForSelectedItems()?.forEach({ (indexPath) -> () in
            //DB.sharedInstance.delete(self.videos[indexPath.row])
            // TODO: エラー処理
            self.videos[indexPath.row].delete()
        })
        HUD.sharedInstance.dismissLoading()
        fetch()
        setEditing(false, animated: true)
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
            if collectionView.indexPathsForSelectedItems()?.count > 0 {
                navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "finishEditing"), animated: true)
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        } else {
            performSegueWithIdentifier(R.segue.watchVideo, sender: videos[indexPath.row])
        }
    }

    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if editing {
            if collectionView.indexPathsForSelectedItems()?.count > 0 {
                navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: "finishEditing"), animated: true)
            } else {
                navigationItem.rightBarButtonItem = nil
            }
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
    //@IBOutlet weak var checkView: UIImageView!

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