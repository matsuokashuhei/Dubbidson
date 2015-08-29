//
//  Notificator.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/30.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import SVProgressHUD

class Notificator {

    static let sharedInstance = Notificator()

    func showLoading() {
        SVProgressHUD.show()
    }

    func dismissLoading() {
        SVProgressHUD.dismiss()
    }

    func showError(error: NSError) {
        SVProgressHUD.showErrorWithStatus(error.localizedDescription)
    }

}