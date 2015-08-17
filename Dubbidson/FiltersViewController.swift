//
//  FiltersViewController.swift
//  Dubski
//
//  Created by matsuosh on 2015/08/16.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

import GPUImage
import XCGLogger

protocol FiltersViewControllerDeleage {
    func selectFilter(filterOperator: FilterOperator)
}

class FiltersViewController: UIViewController {

    @IBOutlet weak var filterNameLabel: UILabel!

    @IBOutlet weak var captureView: GPUImageView!

    @IBOutlet weak var slider: UISlider! {
        didSet {
            slider.addTarget(self, action: "sliderValueChanged", forControlEvents: .ValueChanged)
            slider.hidden = true
        }
    }

    @IBOutlet weak var filtersView: FiltersView! {
        didSet { filtersView.delegate = self }
    }

    @IBOutlet weak var closeButton: UIButton! {
        didSet { closeButton.addTarget(self, action: "closeButtonTapped", forControlEvents: .TouchUpInside) }
    }

    @IBOutlet weak var checkButton: UIButton! {
        didSet { checkButton.addTarget(self, action: "checkButtonTapped", forControlEvents: .TouchUpInside) }
    }

    let logger = XCGLogger.defaultInstance()

    var camera = Camera.sharedInstance

    var filterOperator: FilterOperator! {
        didSet {
            if let oldValue = oldValue {
                oldValue.filter.removeTarget(captureView)
            }
            if let label = filterNameLabel {
                label.text = filterOperator.name
            }
        }
    }

    var artworkImage: UIImage?

    var delegate: FiltersViewControllerDeleage?

    override func viewDidLoad() {
        super.viewDidLoad()

        filterNameLabel.text = filterOperator.name

        filtersView.artworkImage = self.artworkImage
        filtersView.setFilterOperators(filterOperators)
        filtersView.setSelectedFilterOperator(filterOperator)
        filtersView.startOutput()

        camera.addTarget(filterOperator.filter as! GPUImageInput)
        filterOperator.filter.addTarget(captureView)

        switch filterOperator.sliderConfiguration {
        case .Disabled:
            slider.hidden = true
        case let .Enabled(minimumValue, maximumValue, initialValue):
            slider.minimumValue = minimumValue
            slider.maximumValue = maximumValue
            slider.value = initialValue
            slider.hidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - IB Actions
extension FiltersViewController {

    func checkButtonTapped() {
        delegate?.selectFilter(filterOperator)
        dismissViewControllerAnimated(true, completion: nil)
    }

    func closeButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func sliderValueChanged() {
        switch filterOperator.sliderConfiguration {
        case let .Enabled(minimumValue, maximumValue, initialValue):
            filterOperator.updateBasedOnSlider(value: CGFloat(slider.value))
        case .Disabled:
            break
        }
    }

}

// MARK: - Filters view delegate
extension FiltersViewController: FiltersViewDelegate {

    func filtersViewDidSelect(filterOperator: FilterOperator) {
        self.filterOperator = filterOperator
        switch filterOperator.sliderConfiguration {
        case .Disabled:
            slider.hidden = true
        case let .Enabled(minimumValue, maximumValue, initialValue):
            slider.minimumValue = minimumValue
            slider.maximumValue = maximumValue
            slider.value = initialValue
            slider.hidden = false
        }
        filterOperator.filter.addTarget(captureView)
    }

}