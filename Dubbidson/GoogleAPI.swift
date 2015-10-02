//
//  Google.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/29.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import Alamofire
import PromiseKit
//import Result
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

    //func suggestions(keyword keyword: String, handler: (ATResult<[String], NSError>.t) -> ()) {
    func suggestions(keyword keyword: String, handler: (Result<[String], NSError>) -> ()) {
        let URL = "https://suggestqueries.google.com/complete/search"
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
        request.responseJSON { response in
            switch response.result {
            case .Success(let value):
                guard let JSON = value as? NSArray else {
                    handler(.Failure(NSError.errorWithAppError(.JSONParseFailed)))
                    return
                }
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
                handler(.Success(suggestions))
            case .Failure(let error):
                handler(.Failure(error))
            }
        }
    }

    func suggestions(keyword keyword: String) -> Promise<[String]> {
        return Promise { fulfill, reject in
            suggestions(keyword: keyword) { (result) in
                switch result {
                case .Success(let value):
                    fulfill(value)
                case .Failure(let error):
                    reject(error)
                }

            }
        }
    }

}

extension GoogleAPI {

    //class func suggestions(keyword keyword: String, handler: (ATResult<[String], NSError>.t) -> ()) {
    class func suggestions(keyword keyword: String, handler: (Result<[String], NSError>) -> ()) {
        GoogleAPI.sharedInstance.suggestions(keyword: keyword, handler: handler)
    }

}