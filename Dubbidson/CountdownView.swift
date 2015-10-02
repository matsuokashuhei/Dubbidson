//
//  CircleCountdownView.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/09/12.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit
import XCGLogger
import Async

protocol CountdownViewDelegate {
    func countdownDidFinish(circleView: CountdownView)
}


class CountdownView: UIView {

    let logger = XCGLogger.defaultInstance()

    private var degrees: Double = 0
    private var timeInSeconds: Double = 0
    private let timeInterval: Double = 1

    var delegate: CountdownViewDelegate?

    override func drawRect(rect: CGRect) {
        backgroundColor = UIColor.clearColor()
        drawCircle(rect)
        drawTime(rect)
    }

    private func degreesToRadians(degrees: Double) -> Double {
        return M_PI * degrees / 180 - M_PI_2
    }

    private func drawCircle(rect: CGRect) {
        UIColor.redColor().setStroke()
        let lineWidth: CGFloat = 10.0
        let radius = CGRectGetWidth(rect) / 2.0 - lineWidth / 2.0
        let path = UIBezierPath(arcCenter: CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect)), radius: radius, startAngle: -CGFloat(M_PI_2), endAngle: CGFloat(degreesToRadians(degrees)), clockwise: true)
        path.lineWidth = lineWidth
        path.setLineDash([10, 5], count: 2, phase: 0.0)
        path.stroke()
    }

    private func drawTime(rect: CGRect) {
        let text: NSString = NSString(format: "%.0f", timeInSeconds)
        let font = UIFont(name: "AvenirNext-Regular", size: 100.0)!
        let size = text.sizeWithAttributes([NSFontAttributeName: font])
        let attributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.redColor(),
            NSParagraphStyleAttributeName: NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        ]
        let textRect = CGRectInset(rect, (CGRectGetWidth(rect) - size.width) / 2.0, (CGRectGetHeight(rect) - size.height) / 2.0)
        text.drawInRect(textRect, withAttributes: attributes)
    }

    func startWithSeconds(seconds: Double) {
        timeInSeconds = seconds
        degrees = 0
        update()
        updateTime()
    }

    func update() {
        degrees += 360.0 / 30.0
        if timeInSeconds > 0 {
            NSTimer.scheduledTimerWithTimeInterval(1.0 / 30.0, target: self, selector: "update", userInfo: nil, repeats: false)
            setNeedsDisplay()
        } else {
            setNeedsDisplay()
            delegate?.countdownDidFinish(self)
        }
        if degrees == 360 {
            degrees = 0
        }
    }

    func updateTime() {
        timeInSeconds -= timeInterval
        if timeInSeconds > 0 {
            NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: "updateTime", userInfo: nil, repeats: false)
        } else {
            delegate?.countdownDidFinish(self)
        }
    }

}

class CountdownTimer {

    let logger = XCGLogger.defaultInstance()

    static let sharedInstance = CountdownTimer()

    var delegate: CountdownTimerDelegate?

    typealias CompletionHandler = () -> ()
    
    var completionHandler: CompletionHandler?

    func showWithSeconds(seconds: Float, view: UIView, size: CGSize = CGSize(width: 200, height: 200), completion: () ->()) {
    //func showWithSeconds(seconds: Float, view: UIView, size: CGSize = CGSize(width: 200, height: 200)) {
        removeCircleViewFromView(view)
        let circleView = CountdownView(frame: frameOfCircleViewOfSize(size, view: view))
        circleView.backgroundColor = UIColor.clearColor()
        logger.debug("circleView.frame: \(circleView.frame)")
        view.addSubview(circleView)
        circleView.delegate = self
        completionHandler = completion
        circleView.startWithSeconds(4)
    }

    func stop() {
    }

    func removeCircleViewFromView(view: UIView) {
        logger.verbose("")
        if let prevCircleView = circleViewInView(view) {
            prevCircleView.removeFromSuperview()
            logger.debug("prevCircleViewを消しました。")
        }
    }

    func circleViewInView(view: UIView) -> CountdownView? {
        let views = view.subviews.filter { (view) -> Bool in
            return view.isKindOfClass(CountdownView)
        }
        return views.first as? CountdownView
    }

    func frameOfCircleViewOfSize(size: CGSize, view: UIView) -> CGRect {
        logger.verbose("size: \(size)")
        logger.verbose("view.bounds: \(view.bounds)")
        logger.verbose("CGRectGetWidth(view.bounds): \(CGRectGetWidth(view.bounds))")
        logger.verbose("CGRectGetHeight(view.bounds): \(CGRectGetHeight(view.bounds))")
        let rectInset = CGRectInset(view.bounds, (CGRectGetWidth(view.bounds) - size.width) / 2.0, (CGRectGetHeight(view.bounds) - size.height) / 2.0)
        logger.verbose("rectInset: \(rectInset)")
        return rectInset
    }

}
protocol CountdownTimerDelegate {
    func countdownTimerDidFinish()
}

extension CountdownTimer: CountdownViewDelegate {

    func countdownDidFinish(countdownView: CountdownView) {
        logger.verbose("")
        //countdownView.removeFromSuperview()
        //delegate?.countdownTimerDidFinish()
        if let completionHandler = self.completionHandler {
            completionHandler()
        }
    }
    
}