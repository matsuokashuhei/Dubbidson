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
    func selectFilter(filter: Filterable)
}

class FiltersViewController: UIViewController {

    @IBOutlet weak var filterNameLabel: UILabel! {
        didSet {
            if let filter = self.filter {
                filterNameLabel.text = filter.name
            }
        }
    }

    @IBOutlet weak var captureView: GPUImageView! {
        didSet {
            filter.addTarget(captureView)
        }
    }

    /*
    @IBOutlet weak var slider: UISlider! {
        didSet {
            slider.addTarget(self, action: "sliderValueChanged", forControlEvents: .ValueChanged)
            slider.hidden = true
        }
    }
    */

    @IBOutlet weak var selectionView: FilterSelectionView! {
        didSet {
            selectionView.delegate = self
        }
    }

    @IBOutlet weak var closeButton: UIButton! {
        didSet { closeButton.addTarget(self, action: "closeButtonTapped", forControlEvents: .TouchUpInside) }
    }

    @IBOutlet weak var checkButton: UIButton! {
        didSet { checkButton.addTarget(self, action: "checkButtonTapped", forControlEvents: .TouchUpInside) }
    }

    let logger = XCGLogger.defaultInstance()

    var camera = Camera.sharedInstance

    var filter: Filterable! {
        didSet {
            if let prevFilter = oldValue {
                prevFilter.removeTarget(captureView)
            }
            if let label = filterNameLabel {
                label.text = filter.name
            }
        }
    }

    var blendImage: UIImage?

    var delegate: FiltersViewControllerDeleage?

    override func viewDidLoad() {
        super.viewDidLoad()

        selectionView.blendImage = self.blendImage
        selectionView.setFilters(filters)
        selectionView.setSelectedFilter(filter)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        selectionView.startOutput()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        selectionView.endOutput()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: - IB Actions
extension FiltersViewController {

    func checkButtonTapped() {
        delegate?.selectFilter(filter)
        dismissViewControllerAnimated(true, completion: nil)
    }

    func closeButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    func sliderValueChanged() {
        switch filterOperator.sliderConfiguration {
        case let .Enabled(minimumValue, maximumValue, initialValue):
            filterOperator.updateBasedOnSlider(value: CGFloat(slider.value))
        case .Disabled:
            break
        }
    }
    */

}

// MARK: - Filters view delegate
extension FiltersViewController: FilterSelectionViewDelegate {

    func filtersViewDidSelect(filter: Filterable) {
        /*
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
        */
        self.filter = filter
        camera.addTarget(filter)
        filter.addTarget(captureView)
    }

}