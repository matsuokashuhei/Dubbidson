//
//  Notificator.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/30.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import SVProgressHUD
//import NVActivityIndicatorView

class HUD {

    static let sharedInstance = HUD()

    var isRunning = false

    init() {
        SVProgressHUD.setRingThickness(4.0)
        SVProgressHUD.setForegroundColor(UIColor.mainColor)
        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
        /*
        SVProgressHUD.appearance().tintColor = UIColor.mainColor
        SVProgressHUD.appearance().defaultStyle = .Light
        SVProgressHUD.appearance().defaultMaskType = .Gradient
        SVProgressHUD.appearance().defaultAnimationType = .Native
        SVProgressHUD.appearance().ringThickness = 4.0
        SVProgressHUD.appearance().ringRadius = 72.0
        SVProgressHUD.appearance().backgroundColor = UIColor.clearColor()
        */
    }

    func showLoading() {
        if isRunning == false {
            SVProgressHUD.show()
            isRunning = true
        }
    }

    func dismissLoading() {
        if isRunning {
            SVProgressHUD.dismiss()
            isRunning = false
        }
    }

    func showError(error: NSError) {
        SVProgressHUD.showErrorWithStatus(error.localizedDescription)
    }

}