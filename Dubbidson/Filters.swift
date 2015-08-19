//
//  Filters.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/20.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import GPUImage

typealias FilterSetupFunction = () -> GPUImageOutput

enum FilterType {
    case Normal
    case Blend
    case Custom(setupFunction: FilterSetupFunction)
}

protocol Filterable {
    var input: GPUImageInput { get }
    var output: GPUImageOutput { get }
    var name: String { get }
    var type: FilterType { get }
    func addTarget(target: GPUImageInput)
    func removeTarget(target: GPUImageInput)
}

class Filter<T: GPUImageOutput where T: GPUImageInput>: Filterable {

    let filter: T
    let type: FilterType
    let name: String

    init(name: String, type: FilterType) {
        self.type = type
        self.name = name
        switch type {
        case .Normal, .Blend:
            filter = T()
        case let .Custom(setupFunction: setupFunction):
            filter = setupFunction() as! T
        }
    }

    var input: GPUImageInput {
        return filter
    }

    var output: GPUImageOutput {
        return filter
    }

    func addTarget(target: GPUImageInput) {
        filter.addTarget(target)
    }

    func removeTarget(target: GPUImageInput) {
        filter.removeTarget(target)
    }

}

let filters: [Filterable] = [
    Filter<GPUImageFilter>(name: "Normal", type: .Normal),
    Filter<GPUImageSepiaFilter>(name: "Sepia", type: .Normal),
    Filter<GPUImageGrayscaleFilter>(name: "Grayscale", type: .Normal),
    Filter<GPUImageAmatorkaFilter>(name: "Amatorka", type: .Normal),
    Filter<GPUImageMissEtikateFilter>(name: "Miss Etikate", type: .Normal),
    Filter<GPUImageSoftEleganceFilter>(name: "Soft elegance", type: .Normal),
    Filter<GPUImageSoftLightBlendFilter>(name: "Soft elegance", type: .Blend),
    Filter<GPUImageMonochromeFilter>(name: "Monochrome", type: .Custom(setupFunction: { () -> GPUImageOutput in
        let filter = GPUImageMonochromeFilter()
        filter.color = GPUVector4(one: 0.0, two: 0.0, three: 1.0, four: 1.0)
        return filter
    })),
]