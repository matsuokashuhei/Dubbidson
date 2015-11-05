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
    func didSelectSuggestion(suggestion: String)
}

class SuggestionsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView(frame: CGRectZero)
        }
    }

    let logger = XCGLogger.defaultInstance()

    var keyword: String = "" {
        didSet {
            fetch(keyword: keyword)
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

    func fetch(keyword keyword: String) {
        GoogleAPI.suggestions(keyword: keyword) { (result) in
            switch result {
            case .Success(let suggestions):
                self.suggestions = suggestions
            case .Failure(let error):
                self.logger.error(error.localizedDescription)
            }
        }
    }
}

extension SuggestionsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectSuggestion(suggestions[indexPath.row])
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