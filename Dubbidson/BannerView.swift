//
//  BannerView.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/09/04.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import iAd
import UIKit

import GoogleMobileAds
import XCGLogger

protocol BannerViewDelegate {
    func showBanner()
    func hideBanner()
}

class BannerView: UIView {

    let logger = XCGLogger.defaultInstance()

    var iAdView: ADBannerView!
    var adMobView: GADBannerView!

    var bannerLoaded = false

    var delegate: BannerViewDelegate?

    convenience init(rootViewController: UIViewController) {
        self.init()
        // iAd
        iAdView = ADBannerView(adType: .Banner)
        iAdView.delegate = self
        addSubview(iAdView)
        // AdMob
        adMobView = {
            let view = GADBannerView(adSize: kGADAdSizeBanner)
            view.adUnitID = "ca-app-pub-5621609150019172/4483051644"
            view.rootViewController = rootViewController
            view.delegate = self
            return view
        }()
        addSubview(adMobView)
        let request = GADRequest()
        if Platform.isSimulator {
            request.testDevices = [kGADSimulatorID];
        } else {
            request.testDevices = ["d2e66d2385b86a98f0f635545a058f37"]
        }
        adMobView.loadRequest(request)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        iAdView.frame = bounds
        adMobView.frame = bounds
    }

    override func sizeThatFits(size: CGSize) -> CGSize {
        return iAdView.sizeThatFits(size)
    }

    private func show(bannerView: UIView) {
        bannerLoaded = true
        bringSubviewToFront(bannerView)
        delegate?.showBanner()
    }

    private func hide(bannerView: UIView) {
        bannerLoaded = false
        delegate?.hideBanner()
    }

}

extension BannerView: ADBannerViewDelegate {

    func bannerViewDidLoadAd(banner: ADBannerView!) {
        logger.verbose("")
        show(iAdView)
    }

    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        logger.verbose("")
        hide(iAdView)
        let request = GADRequest()
        if Platform.isSimulator {
            request.testDevices = [kGADSimulatorID];
        } else {
            request.testDevices = ["d2e66d2385b86a98f0f635545a058f37"]
        }
        adMobView.loadRequest(request)
    }

}

extension BannerView: GADBannerViewDelegate {

    func adViewDidReceiveAd(bannerView: GADBannerView!) {
        logger.verbose("iAdView.bannerLoaded: \(iAdView.bannerLoaded)")
        if iAdView.bannerLoaded {
            return
        }
        show(adMobView)
    }

    func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        logger.verbose("iAdView.bannerLoaded: \(iAdView.bannerLoaded)")
        if iAdView.bannerLoaded {
            return
        }
        hide(adMobView)
    }

}
