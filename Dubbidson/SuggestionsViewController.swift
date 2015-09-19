//
//  SuggestionsViewController.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/29.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import UIKit

import XCGLogger

protocol SuggestionsViewControllerDelegate {
    func didSelectKeyword(keyword: String)
}

class SuggestionsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            logger.debug("")
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView(frame: CGRectZero)
        }
    }

    let logger = XCGLogger.defaultInstance()

    var keyword: String = "" {
        didSet {
            fetch(keyword)
        }
    }
    var suggestions = [String]() {
        didSet {
            tableView.reloadData()
        }
    }

    var delegate: SuggestionsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        logger.verbose("")
    }

    func fetch(keyword: String) {
        GoogleAPI.sharedInstance.suggestions(keyword: keyword).then { (suggestions) in
            self.suggestions = suggestions
//        }.catch { (error) in
//            self.logger.error(error.localizedDescription)
        }
    }
}

extension SuggestionsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectKeyword(suggestions[indexPath.row])
    }

}

extension SuggestionsViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.suggestionTableViewCell, forIndexPath: indexPath)!
        cell.suggestionLabel.text = suggestions[indexPath.row]
        return cell
    }

}

class SuggestionTableViewCell: UITableViewCell {
    @IBOutlet weak var suggestionLabel: UILabel!
}