//
//  FilterView.swift
//  GPUImageTest
//
//  Created by matsuosh on 2015/07/27.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

import GPUImage
import XCGLogger

class FilterView: UIView {

    let logger = XCGLogger.defaultInstance()

    let squareFilter = GPUImageCropFilter(cropRegion: CGRect(x: 0.0, y: 0.125, width: 1.0, height: 0.75))
    var filterOperator: FilterOperator!
    var view: GPUImageView!
    var image: UIImage?
    var selected = false
    var blendImage: GPUImagePicture?

    convenience init(filterOperator: FilterOperator, selected: Bool = false) {
        self.init()
        self.filterOperator = filterOperator
        self.selected = selected
        view = GPUImageView()
        view.userInteractionEnabled = false
        addSubview(view)
    }

    override func layoutSubviews() {
        view.frame = self.bounds
    }

    func startOutput() {
        let camera = Camera.sharedInstance
        switch filterOperator.operationType {
        case .SingleInput:
            if selected == false {
                camera.addTarget(filterOperator.filter as! GPUImageInput)
            }
            filterOperator.filter.addTarget(squareFilter)
            squareFilter.addTarget(view)
        case .Blend:
            if selected == false {
                camera.addTarget(filterOperator.filter as! GPUImageInput)
            }
            if let image = self.image {
                let rect = CGRect(x: image.size.width * 0.125, y: 0.0, width: image.size.width * 0.75, height: image.size.height)
                let ref = CGImageCreateWithImageInRect(image.CGImage, rect)
                let croppedImage = UIImage(CGImage: ref)
                blendImage = GPUImagePicture(image: croppedImage)
                blendImage?.addTarget(filterOperator.filter as! GPUImageInput)
                blendImage?.processImage()
            }
            filterOperator.filter.addTarget(squareFilter)
            squareFilter.addTarget(view)
        case let .Custom1(function: setupFunction):
            let inputToFunction: (GPUImageOutput, GPUImageOutput?) = setupFunction(camera: camera.camera, output: squareFilter)
            filterOperator.configureCustomFilter(inputToFunction)
            squareFilter.addTarget(view)
        case let .Custom2(function: setupFunction):
            let inputToFunction: (GPUImageOutput, GPUImageOutput?) = setupFunction(camera: camera.camera, output: view)
            filterOperator.configureCustomFilter(inputToFunction)
            filterOperator.filter.addTarget(squareFilter)
            squareFilter.addTarget(view)
        }
    }

    func endOutput() {
        if selected == false {
            let camera = Camera.sharedInstance
            camera.removeTarget(filterOperator.filter as! GPUImageInput)
        }
        filterOperator.filter.removeTarget(squareFilter)
        if let blendImage = self.blendImage {
            blendImage.removeTarget(filterOperator.filter as! GPUImageInput)
        }
        squareFilter.removeTarget(view)
    }

}
