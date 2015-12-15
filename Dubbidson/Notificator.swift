//
//  Notificator.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/30.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import SVProgressHUD

class HUD {

    static let sharedInstance = HUD()

    var isRunning = false

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