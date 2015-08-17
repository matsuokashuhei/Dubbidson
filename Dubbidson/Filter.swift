//
//  Filter.swift
//  Dubski
//
//  Created by matsuosh on 2015/08/16.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import GPUImage

let filterOperators: [FilterOperator] = [
    FilterOperation<GPUImageFilter>(
        name: "Normal",
        operationType: .SingleInput,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageSepiaFilter>(
        name: "Sepia",
        operationType: .SingleInput,
        sliderConfiguration: .Enabled(minimumValue: 0.0, maximumValue: 1.0, initialValue: 1.0),
        sliderUpdateCallback: { (filter, vale) -> () in
            filter.intensity = vale
        },
        sliderValue: { (filter) -> CGFloat in
            return filter.intensity as CGFloat
        }
    ),
    FilterOperation<GPUImageAmatorkaFilter>(
        name: "Amatorka",
        operationType: .SingleInput,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageMissEtikateFilter>(
        name: "Miss Etikate",
        operationType: .SingleInput,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageSoftEleganceFilter>(
        name: "Soft elegance",
        operationType: .SingleInput,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageSoftLightBlendFilter>(
        name: "Soft light blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    )
]