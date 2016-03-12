//
//  BannerViewController.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/09/06.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

import XCGLogger

let BannerViewShowNotification = "BannerViewShowNotification"
let BannerViewHideNotification = "BannerViewHideNotification"

class BannerViewController: UIViewController {

    let logger = XCGLogger.defaultInstance()

    var bannerView: BannerView!
    var contentController: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        bannerView = BannerView(rootViewController: self)
        bannerView.delegate = self
        view.addSubview(bannerView)
        contentController = childViewControllers.first!
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //logger.verbose("view.bounds: \(view.bounds)")
        var contentFrame = view.bounds
        var bannerFrame = CGRectZero
        bannerFrame.size = bannerView.sizeThatFits(contentFrame.size)
        //logger.verbose("bannerFrame: \(bannerFrame)")
        //logger.verbose("bannerView.bannerLoaded: \(bannerView.bannerLoaded)")
        if bannerView.bannerLoaded {
            contentFrame.size.height -= (bannerFrame.size.height + 49.0)
            bannerFrame.origin.y = contentFrame.size.height
        } else {
            bannerFrame.origin.y = contentFrame.size.height
        }
        contentController.view.frame = contentFrame
        bannerView.frame = bannerFrame
        //logger.verbose("contentFrame: \(contentFrame)")
        //logger.verbose("bannerFrame: \(bannerFrame)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension BannerViewController: BannerViewDelegate {

    func showBanner() {
        UIView.animateWithDuration(0.25) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: BannerViewShowNotification, object: self))
    }

    func hideBanner() {
        UIView.animateWithDuration(0.25) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: BannerViewHideNotification, object: self))
    }

}