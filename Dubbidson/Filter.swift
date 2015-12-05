//
//  Filters.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/20.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import GPUImage

typealias CongigurationFunction = () -> GPUImageOutput

enum FilterType {
    case Normal
    case Blend
    case Custom(configurationFunction: CongigurationFunction)
}

protocol Filterable {
    var input: GPUImageInput { get }
    var output: GPUImageOutput { get }
    var name: String { get }
    var type: FilterType { get }
    func addTarget(target: GPUImageInput)
    func addTarget(view: GPUImageView)
    func removeTarget(target: GPUImageInput)
}

public class Filter<T: GPUImageOutput where T: GPUImageInput>: Filterable {

    let filter: T
    let type: FilterType
    let name: String

    init(name: String, type: FilterType) {
        self.type = type
        self.name = name
        switch type {
        case .Normal, .Blend:
            filter = T()
        case let .Custom(configurationFunction: configure):
            filter = configure() as! T
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

    func addTarget(view: GPUImageView) {
        filter.forceProcessingAtSize(view.sizeInPixels)
        filter.addTarget(view)
    }

    func removeTarget(target: GPUImageInput) {
        filter.removeTarget(target)
    }

}

/*
extension Filter: Equatable {}
public func ==<T: GPUImageOutput where T: GPUImageInput>(lhs: Filter<T>, rhs: Filter<T>) -> Bool {
    return lhs.name == rhs.name
}
*/

func groupFilters(filters: [GPUImageOutput]) -> GPUImageFilterGroup {
    let filterGroup = GPUImageFilterGroup()
    for filter in filters {
        filterGroup.addTarget(filter as! GPUImageInput)
    }
    filterGroup.initialFilters = [filters.first!]
    filterGroup.terminalFilter = filters.last!
    for (index,filter) in filters.enumerate() {
        if filter == filters.last! {
            continue
        }
        filters[index].addTarget(filters[index + 1] as! GPUImageInput)
    }
    return filterGroup
}

let filters: [Filterable] = [
    Filter<GPUImageFilter>(name: "Normal", type: .Normal),
    Filter<GPUImageAmatorkaFilter>(name: "Amatorka", type: .Normal),
    Filter<GPUImageMissEtikateFilter>(name: "Miss Etikate", type: .Normal),
    Filter<GPUImageSoftEleganceFilter>(name: "Soft elegance", type: .Normal),
    //Filter<GPUImageSepiaFilter>(name: "Sepia", type: .Normal),
    Filter<GPUImageSepiaFilter>(name: "Sepia", type: .Normal),
    Filter<GPUImageFilterGroup>(name: "Sepia + Amatorka", type: .Custom(configurationFunction: { () -> GPUImageOutput in
        return groupFilters([GPUImageSepiaFilter(), GPUImageAmatorkaFilter()])
    })),
    /*
    Filter<GPUImageFilterGroup>(name: "Sepia + Miss Etikate + Vignette", type: .Custom(configurationFunction: { () -> GPUImageOutput in
        return groupFilters([GPUImageSepiaFilter(), GPUImageMissEtikateFilter(), GPUImageVignetteFilter()])
    })),
    */
    Filter<GPUImageFilterGroup>(name: "Sepia + Miss Etikate", type: .Custom(configurationFunction: { () -> GPUImageOutput in
        return groupFilters([GPUImageSepiaFilter(), GPUImageMissEtikateFilter()])
    })),
    Filter<GPUImageFilterGroup>(name: "Sepia + Soft elegance", type: .Custom(configurationFunction: { () -> GPUImageOutput in
        return groupFilters([GPUImageSepiaFilter(), GPUImageSoftEleganceFilter()])
    })),
    Filter<GPUImageGrayscaleFilter>(name: "Grayscale", type: .Normal),
    Filter<GPUImageFilterGroup>(name: "Grayscale + Amatorka", type: .Custom(configurationFunction: { () -> GPUImageOutput in
        return groupFilters([GPUImageGrayscaleFilter(), GPUImageAmatorkaFilter()])
    })),
    Filter<GPUImageFilterGroup>(name: "Grayscale + Miss Etikate", type: .Custom(configurationFunction: { () -> GPUImageOutput in
        return groupFilters([GPUImageGrayscaleFilter(), GPUImageMissEtikateFilter()])
    })),
    Filter<GPUImageFilterGroup>(name: "Grayscale + Soft elegance", type: .Custom(configurationFunction: { () -> GPUImageOutput in
        return groupFilters([GPUImageGrayscaleFilter(), GPUImageSoftEleganceFilter()])
    })),
    Filter<GPUImageOverlayBlendFilter>(name: "Overlay blend", type: .Blend),
    Filter<GPUImageSoftLightBlendFilter>(name: "Soft light blend", type: .Blend),
    /*
    Filter<GPUImageMonochromeFilter>(name: "Monochrome", type: .Custom(configurationFunction: { () -> GPUImageOutput in
        let filter = GPUImageMonochromeFilter()
        filter.color = GPUVector4(one: 0.0, two: 0.0, three: 1.0, four: 1.0)
        return filter
    })),
    */
]