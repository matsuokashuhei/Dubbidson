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
    func didSelectFilter(filter: Filterable)
}

class FiltersViewController: UIViewController {

    @IBOutlet weak var filterNameLabel: UILabel! {
        didSet {
            if let filter = self.capturedFilter {
                filterNameLabel.text = filter.name
            }
        }
    }

    @IBOutlet weak var captureView: GPUImageView! {
        didSet {
            capturedFilter.addTarget(captureView)
        }
    }

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

    var selectedFilter: Filterable! {
        didSet {
            capturedFilter = selectedFilter
        }
    }
    var capturedFilter: Filterable! {
        didSet {
            if let prevFilter = oldValue {
                prevFilter.removeTarget(captureView)
            }
            if let label = filterNameLabel {
                label.text = capturedFilter.name
            }
        }
    }

    var blendImage: UIImage?

    var delegate: FiltersViewControllerDeleage?

    override func viewDidLoad() {
        super.viewDidLoad()

        selectionView.blendImage = self.blendImage
        selectionView.setFilters(filters)
        selectionView.setSelectedFilter(capturedFilter)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
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
        delegate?.didSelectFilter(capturedFilter)
        dismissViewControllerAnimated(true, completion: nil)
    }

    func closeButtonTapped() {
        selectionView.setSelectedFilter(selectedFilter)
        dismissViewControllerAnimated(true, completion: nil)
    }

}

// MARK: - Filters view delegate
extension FiltersViewController: FilterSelectionViewDelegate {

    func filtersViewDidSelect(filter: Filterable) {
        //self.filter = filter
        self.capturedFilter = filter
        camera.addTarget(filter)
        filter.addTarget(captureView)
    }

}