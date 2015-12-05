//
//  Camera.swift
//  GPUImageTest
//
//  Created by matsuosh on 2015/07/28.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import GPUImage
import XCGLogger

protocol CameraDelegate {
    func recordingCompleted(outputURL: NSURL)
    func recordingFailed(error: NSError)
}

class Camera: NSObject {

    static let sharedInstance = Camera()

    let logger = XCGLogger.defaultInstance()

    let camera: GPUImageVideoCamera
    let squareFilter: GPUImageCropFilter

    private override init() {
        if Platform.isSimulator {
            camera = GPUImageVideoCamera()
            squareFilter = GPUImageCropFilter(cropRegion: CGRect(x: 0.0, y: 0.125, width: 1.0, height: 0.75))
        } else {
            camera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Front)
            camera.outputImageOrientation = .Portrait
            camera.horizontallyMirrorFrontFacingCamera = true
            squareFilter = GPUImageCropFilter(cropRegion: CGRect(x: 0.0, y: 0.125, width: 1.0, height: 0.75))
            camera.addTarget(squareFilter)
        }
        super.init()
    }

    func addTarget(target: GPUImageInput) {
        squareFilter.addTarget(target)
    }

    func addTarget(filter: Filterable) {
        //squareFilter.addTarget(filter.output as! GPUImageInput)
        squareFilter.addTarget(filter.input)
    }

    func removeTarget(filter: Filterable) {
        //squareFilter.removeTarget(filter.output as! GPUImageInput)
        squareFilter.removeTarget(filter.input)
    }

    func startCapture() {
        camera.startCameraCapture()
    }

    func stopCapture() {
        camera.stopCameraCapture()
    }

}
