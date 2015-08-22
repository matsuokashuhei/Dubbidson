//
//  NetworkIndicator.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/22.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation
import UIKit

class NetworkIndicator {

    static let sharedInstance = NetworkIndicator()

    private init() {
    }

    func show() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    func dissmiss() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

}