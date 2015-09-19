//
//  CircleCountdownView.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/09/12.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

class CircleCountdownView: UIView {

    let circleBorderWidth: CGFloat = 6.0
    let circleColor = UIColor.redColor()
    var cirleSegs: Float = 0

    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        // 線の太さ
        CGContextSetLineWidth(context, circleBorderWidth)
        CGContextSetStrokeColorWithColor(context, circleColor.CGColor)
        // パスの作成
        CGContextBeginPath(context)

        // サークルの半径
        let radius = CGRectGetWidth(rect) / 2.0 - circleBorderWidth / 2.0
        let angleOffset = CGFloat(M_PI_2)
        //let endAngle = CGFloat(cicleSegs)
    }
}
