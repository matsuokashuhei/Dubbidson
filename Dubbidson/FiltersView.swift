//
//  FiltersView.swift
//  Dubski
//
//  Created by matsuosh on 2015/08/16.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import GPUImage
import XCGLogger

protocol FiltersViewDelegate {
    func filtersViewDidSelect(filterOperator: FilterOperator)
}

class FiltersView: UIView {

    @IBOutlet weak var scrollView: UIScrollView!

    let logger = XCGLogger.defaultInstance()

    var filterOperators = [FilterOperator]()
    var filterViews = [FilterView]()
    var artworkImage: UIImage?

    var delegate: FiltersViewDelegate?

    func setFilterOperators(filterOperators: [FilterOperator]) {
        self.filterOperators = filterOperators
        for filterOperator in self.filterOperators {
            switch filterOperator.operationType {
            case .Blend:
                if let artworkImage = self.artworkImage {
                    setFilterOperator(filterOperator)
                }
            default:
                setFilterOperator(filterOperator)
            }
        }
    }
    func setFilterOperator(filterOperator: FilterOperator) {
        let filterView = FilterView(filterOperator: filterOperator)
        filterView.image = artworkImage?.copy() as? UIImage
        filterView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "filterViewTapped:"))
        scrollView.addSubview(filterView)
        filterViews.append(filterView)
    }

    func setSelectedFilterOperator(filterOperator: FilterOperator) {
        let selectedFilterView = filterViews.filter { (filterView) -> Bool in
            return filterView.filterOperator.name == filterOperator.name
        }.first
        if let filterView = selectedFilterView {
            filterView.selected = true
        }
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
    }

    func filterViewTapped(sender: UITapGestureRecognizer) {
        let selectedView = sender.view as! FilterView
        for view in filterViews {
            view.selected = view == selectedView
        }
        delegate?.filtersViewDidSelect(selectedView.filterOperator)
    }

}