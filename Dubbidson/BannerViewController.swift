//
//  BannerViewController.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/09/06.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

import XCGLogger

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

    override func viewWillAppear(animated: Bool) {
        logger.debug("view.frame: \(view.frame)")
        super.viewWillAppear(animated)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        logger.debug("view.frame: \(view.frame)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logger.debug("view.bounds: \(view.bounds)")
        var contentFrame = view.bounds
        var bannerFrame = CGRectZero
        bannerFrame.size = bannerView.sizeThatFits(contentFrame.size)
        logger.debug("bannerFrame: \(bannerFrame)")
        logger.debug("bannerView.bannerLoaded: \(bannerView.bannerLoaded)")
        if bannerView.bannerLoaded {
            contentFrame.size.height -= (bannerFrame.size.height + 49.0)
            //contentFrame.size.height -= bannerFrame.size.height
            bannerFrame.origin.y = contentFrame.size.height
        } else {
            bannerFrame.origin.y = contentFrame.size.height
        }
        contentController.view.frame = contentFrame
        bannerView.frame = bannerFrame
        logger.debug("contentFrame: \(contentFrame)")
        logger.debug("bannerFrame: \(bannerFrame)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BannerViewController: BannerViewDelegate {

    func showBanner() {
        logger.debug("view.bounds: \(view.bounds)")
        logger.debug("contentController.view.bounds: \(self.contentController.view.bounds)")
        UIView.animateWithDuration(0.25) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }

    func hideBanner() {
        UIView.animateWithDuration(0.25) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }

}