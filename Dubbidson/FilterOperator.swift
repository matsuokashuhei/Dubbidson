//
//  FilterOperator.swift
//  Dubski
//
//  Created by matsuosh on 2015/08/16.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import GPUImage
import XCGLogger

typealias Custom1SetupFunction = (camera: GPUImageVideoCamera, output: GPUImageInput) -> (filter: GPUImageOutput, secondOutput: GPUImageOutput?)
typealias Custom2SetupFunction = (camera: GPUImageVideoCamera, output: GPUImageView) -> (filter: GPUImageOutput, secondOutput: GPUImageOutput?)

enum OperationType {
    case SingleInput
    case Blend
    case Custom1(function: Custom1SetupFunction)
    case Custom2(function: Custom2SetupFunction)
}

enum SliderSetting {
    case Disabled
    case Enabled(minimumValue: Float, maximumValue: Float, initialValue: Float)
}

protocol FilterOperator {
    var filter: GPUImageOutput { get }
    var name: String { get }
    var operationType: OperationType { get }
    var sliderConfiguration: SliderSetting { get }
    func configureCustomFilter(input: (filter: GPUImageOutput, secondInput: GPUImageOutput?))
    func updateBasedOnSlider(#value: CGFloat)
    func addTarget(newTarget: GPUImageInput)
    func removeTarget(newTarget: GPUImageInput)
}

class FilterOperation<T: GPUImageOutput where T: GPUImageInput>: FilterOperator {

    let logger = XCGLogger.defaultInstance()

    var internalFilter: T?
    var secondInput: GPUImageOutput?
    let name: String
    let operationType: OperationType
    let sliderConfiguration: SliderSetting
    let sliderUpdateCallback: ((filter: T, value: CGFloat) ->())?
    let sliderValue: ((filter: T) -> CGFloat)?

    init(name: String,
         operationType: OperationType,
         sliderConfiguration: SliderSetting,
         sliderUpdateCallback: ((filter: T, value: CGFloat) -> ())?,
         sliderValue: ((filter: T) -> CGFloat)?) {
        self.name = name
        self.operationType = operationType
        self.sliderConfiguration = sliderConfiguration
        self.sliderUpdateCallback = sliderUpdateCallback
        self.sliderValue = sliderValue
        switch operationType {
        case .SingleInput, .Blend:
            self.internalFilter = T()
        default:
            break
        }
    }

    var filter: GPUImageOutput {
        return internalFilter!
    }

    func configureCustomFilter(input: (filter: GPUImageOutput, secondInput: GPUImageOutput?)) -> () {
        self.internalFilter = (input.filter as! T)
        self.secondInput = input.secondInput
    }

    func updateBasedOnSlider(#value: CGFloat) {
        if let updateFunction = sliderUpdateCallback {
            updateFunction(filter: internalFilter!, value: value)
        }
    }

    func addTarget(newTarget: GPUImageInput) {
        //logger.debug("newTarget: \(newTarget)")
        filter.addTarget(newTarget)
    }

    func removeTarget(newTarget: GPUImageInput) {
        //logger.debug("newTarget: \(newTarget)")
        filter.removeTarget(newTarget)
    }

}