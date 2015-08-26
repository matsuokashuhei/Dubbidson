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

    var filter: Filterable!
    var view: GPUImageView!
    var image: UIImage?
    var selected = false
    var picture: GPUImagePicture?

    convenience init(filter: Filterable) {
        self.init()
        self.filter = filter
        view = GPUImageView()
        view.userInteractionEnabled = false
        addSubview(view)
    }

    override func layoutSubviews() {
        view.frame = self.bounds
    }

    func startOutput() {
        let camera = Camera.sharedInstance
        if selected == false {
            camera.addTarget(filter)
        }
        /*
        switch filter.type {
        case .Normal, .Custom:
            filter.addTarget(view)
        case .Blend:
            if let image = self.image {
                picture = GPUImagePicture(image: image)
                picture?.addTarget(filter.input)
                picture?.processImage()
            }
            filter.addTarget(view)
        }
        */
        switch filter.type {
        case .Blend:
            if let image = self.image {
                picture = GPUImagePicture(image: image)
                picture?.addTarget(filter.input)
                picture?.processImage()
            }
        default:
            break
        }
        filter.addTarget(view)
        filter.output.forceProcessingAtSize(view.sizeInPixels)
    }

    func endOutput() {
        if selected == false {
            Camera.sharedInstance.removeTarget(filter)
        }
        if let picture = self.picture {
            picture.removeTarget(filter.input)
        }
    }

}
