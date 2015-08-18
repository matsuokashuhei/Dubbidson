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
    FilterOperation<GPUImageGrayscaleFilter>(
        name: "Grayscale",
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
    FilterOperation<GPUImagePinchDistortionFilter>(
        name: "Pinch",
        operationType: .SingleInput,
        sliderConfiguration: .Enabled(minimumValue: -2.0, maximumValue: 2.0, initialValue: 0.5),
        sliderUpdateCallback: { (filter, value) -> () in
            filter.scale = value
        },
        sliderValue: { (filter) -> CGFloat in
            return filter.scale
        }
    ),
    FilterOperation<GPUImageSketchFilter>(
        name: "Sketch",
        operationType: .SingleInput,
        sliderConfiguration: .Enabled(minimumValue: 0.0, maximumValue: 1.0, initialValue: 0.5),
        sliderUpdateCallback: { (filter, value) -> () in
            filter.edgeStrength = value
        },
        sliderValue: { (filter) -> CGFloat in
            return filter.edgeStrength
        }
    ),
    FilterOperation<GPUImageToonFilter>(
        name: "Toon",
        operationType: .SingleInput,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImagePosterizeFilter>(
        name: "Posterize",
        operationType: .SingleInput,
        sliderConfiguration: .Enabled(minimumValue: 1.0, maximumValue: 20.0, initialValue: 10.0),
        sliderUpdateCallback: { (filter, vale) -> () in
            filter.colorLevels = UInt(round(vale))
        },
        sliderValue: { (filter) -> CGFloat in
            return CGFloat(filter.colorLevels)
        }
    ),
    FilterOperation<GPUImageAddBlendFilter>(
        name: "Add blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageDivideBlendFilter>(
        name: "Divide blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageMultiplyBlendFilter>(
        name: "Multiply blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageOverlayBlendFilter>(
        name: "Overlay blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageLightenBlendFilter>(
        name: "Lighten blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageDarkenBlendFilter>(
        name: "Darken blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageColorDodgeBlendFilter>(
        name: "Color dodge blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageScreenBlendFilter>(
        name: "Screen blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageDifferenceBlendFilter>(
        name: "Difference blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageSubtractBlendFilter>(
        name: "Subtract blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageExclusionBlendFilter>(
        name: "Exclusion blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageHardLightBlendFilter>(
        name: "Hard light blend",
        operationType: .Blend,
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
    ),
    FilterOperation<GPUImageColorBlendFilter>(
        name: "Color blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageSaturationBlendFilter>(
        name: "Saturation blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImageHueBlendFilter>(
        name: "Hue blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
    FilterOperation<GPUImagePoissonBlendFilter>(
        name: "Poisson blend",
        operationType: .Blend,
        sliderConfiguration: .Disabled,
        sliderUpdateCallback: nil,
        sliderValue: nil
    ),
]