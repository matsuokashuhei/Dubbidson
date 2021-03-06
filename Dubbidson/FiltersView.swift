//
//  FiltersView.swift
//  Dubski
//
//  Created by matsuosh on 2015/08/16.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import GPUImage
import XCGLogger

protocol FilterSelectionViewDelegate {
    func filtersViewDidSelect(filter: Filterable)
}

class FilterSelectionView: UIView {

    @IBOutlet weak var scrollView: UIScrollView!

    let logger = XCGLogger.defaultInstance()

    var filters = [Filterable]()
    var filterViews = [FilterView]()
    var blendImage: UIImage?

    var delegate: FilterSelectionViewDelegate?

    func setFilters(filters: [Filterable]) {
        self.filters = filters
        for filter in filters {
            switch filter.type {
            case .Normal:
                setFilter(filter)
            case .Blend:
                if let _ = self.blendImage {
                    setFilter(filter)
                }
            case .Custom:
                setFilter(filter)
            }
        }
    }

    func setFilter(filter: Filterable) {
        let filterView = FilterView(filter: filter)
        filterView.image = blendImage?.copy() as? UIImage
        filterView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "filterViewTapped:"))
        scrollView.addSubview(filterView)
        filterViews.append(filterView)
    }

    func setSelectedFilter(filter: Filterable) {
        let selectedFilterView = filterViews.filter { (filterView) -> Bool in
            return filterView.filter.name == filter.name
        }.first
        if let filterView = selectedFilterView {
            filterView.selected = true
        }
    }

    var selectedFilterView: FilterView? {
        return filterViews.filter { (filterView) -> Bool in
                return filterView.selected
            }.first
    }

    var indexOfSelectedFilterView: Int {
        guard let selectedFilterView = selectedFilterView else {
            return 0
        }
        guard let index = filterViews.indexOf(selectedFilterView) else {
            return 0
        }
        return index
    }

    func startOutput() {
        for filterView in filterViews {
            filterView.startOutput()
        }
    }

    func endOutput() {
        for filterView in filterViews {
            filterView.endOutput()
        }
    }

    override func layoutSubviews() {
        logger.verbose("")
        let height = self.frame.size.height - 8.0
        let width = height
        let margin: CGFloat = 8.0
        var x = margin
        let y: CGFloat = (frame.height - height) / CGFloat(2)
        for anyObject in scrollView.subviews {
            if let filterView = anyObject as? FilterView {
                filterView.frame = CGRect(x: x, y: y, width: width, height: height)
                x += width + margin
            }
        }
        scrollView.contentSize.width = x
        logger.verbose("scrollView.contentSize.width: \(scrollView.contentSize.width)")
        let contentOffset: CGPoint = {
            let index = CGFloat(indexOfSelectedFilterView)
            logger.verbose("index: \(index)")
            let contentOffset = margin
                + (width * index)
                + (margin * index)
                + (width / 2)
            let x: CGFloat = {
                if contentOffset < self.scrollView.frame.width / 2 {
                    logger.verbose("contentOffset < 0")
                    return 0
                }
                if contentOffset > self.scrollView.contentSize.width - self.scrollView.frame.width / 2 {
                    logger.verbose("contentOffset > self.scrollView.contentSize.width - self.scrollView.frame.width / 2")
                    return self.scrollView.contentSize.width - self.scrollView.frame.width
                }
                return contentOffset - self.scrollView.frame.width / 2
            }()
            return CGPoint(x: x, y: scrollView.contentOffset.y)
        }()
        logger.verbose("contentOffset: \(contentOffset)")
        scrollView.setContentOffset(contentOffset, animated: true)
    }

    func filterViewTapped(sender: UITapGestureRecognizer) {
        let selectedView = sender.view as! FilterView
        for view in filterViews {
            view.selected = view == selectedView
        }
        setNeedsLayout()
        delegate?.filtersViewDidSelect(selectedView.filter)
    }

}