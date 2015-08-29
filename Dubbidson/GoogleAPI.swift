//
//  Google.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/29.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import Alamofire
import Box
import PromiseKit
import Result
import XCGLogger

class GoogleAPI {

    static let sharedInstance = GoogleAPI()

    let logger = XCGLogger.defaultInstance()

    var regionCode = "us"
    var hl = "en_US"

    private init() {
        let locale = NSLocale.currentLocale()
        if let countryCode = locale.objectForKey(NSLocaleCountryCode) as? String {
            regionCode = countryCode
        }
        if let identifier = locale.objectForKey(NSLocaleIdentifier) as? String {
            hl = identifier
        }
    }

    func suggestions(#keyword: String, handler: (Result<[String], NSError>) -> ()) {
        let URL = "http://suggestqueries.google.com/complete/search"
        let parameters = [
            "ds": "yt",
            "hjson": "t",
            "client": "youtube",
            "alt": "json",
            "q": keyword,
            "hl": hl,
            "ie": "utf_8",
            "oe": "utf_8",
        ]
        let request = Alamofire.request(.GET, URL, parameters: parameters)
        //debugPrintln(request)
        request.responseJSON { (_, _, object, error) in
            if let error = error {
                self.logger.error(error.localizedDescription)
                handler(.Failure(Box(error)))
                return
            }
            if let JSON = object as? NSArray {
                var suggestions = [String]()
                if let keywords = JSON[1] as? NSArray {
                    for keyword in keywords {
                        if let keyword = keyword as? NSArray {
                            if let suggestion = keyword[0] as? String {
                                suggestions.append(suggestion)
                            }
                        }
                    }
                }
                handler(.Success(Box(suggestions)))
            } else {
                self.logger.error("")
                handler(.Failure(Box(Error.unknown())))
            }
        }
    }

    func suggestions(#keyword: String) -> Promise<[String]> {
        return Promise { fulfill, reject in
            suggestions(keyword: keyword) { (result) in
                switch result {
                case .Success(let box):
                    fulfill(box.value)
                case .Failure(let box):
                    reject(box.value)
                }

            }
        }
    }

}

extension GoogleAPI {

    class func suggestions(#keyword: String, handler: (Result<[String], NSError>) -> ()) {
        GoogleAPI.sharedInstance.suggestions(keyword: keyword, handler: handler)
    }

}