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

    private override init() {
        camera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Front)
        camera.outputImageOrientation = .Portrait
        camera.horizontallyMirrorFrontFacingCamera = true
        super.init()
    }

    func addTarget(filter: GPUImageInput) {
        camera.addTarget(filter)
    }

    func removeTarget(filter: GPUImageInput) {
        camera.removeTarget(filter)
    }

    func startCapture() {
        camera.startCameraCapture()
    }

    func stopCapture() {
        camera.stopCameraCapture()
    }

}
