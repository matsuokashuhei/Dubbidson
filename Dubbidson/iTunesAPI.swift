//
//  Music.swift
//  Dubski
//
//  Created by matsuosh on 2015/08/16.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import Alamofire
import PromiseKit

class iTunesAPI {

    static let sharedInstance = iTunesAPI()

    var limit: Int
    var country: String

    init() {
        limit = 100
        if let country = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String {
            self.country = country
        } else {
            country = "us"
        }
        /*
        limit = 100
        country = "us"
        */
    }

    func configure(limit limit: Int, country: String) {
        self.limit = limit
        self.country = country
    }

    func topsongs(handler handler: (Result<[Song], NSError>) -> ()) {
        let URL = NSURL(string: "https://itunes.apple.com/\(country)/rss/topsongs/limit=\(limit)/explicit=true/json")!
        let request = Alamofire.request(.GET, URL, parameters: nil)
        NetworkIndicator.sharedInstance.show()
        request.responseJSON() { response in
            NetworkIndicator.sharedInstance.dismiss()
            switch response.result {
            case .Success(let value):
                guard let JSON = value as? NSDictionary else {
                    handler(.Failure(NSError.errorWithAppError(.JSONParseFailed)))
                    return
                }
                guard
                    let feed = JSON["feed"] as? NSDictionary,
                    let entries = feed["entry"] as? [NSDictionary] else {
                    handler(.Success([]))
                    return
                }
                let songs = entries.flatMap({ (entry) -> Song? in
                    return Song(entry: entry)
                })
                handler(.Success(songs))
            case .Failure(let error):
                handler(.Failure(error))
            }
        }
    }

    func topsongs() -> Promise<[Song]> {
        return Promise { (fulfill, reject) in
            topsongs { (result) -> () in
                switch result {
                case .Success(let songs):
                    fulfill(songs)
                case .Failure(let error):
                    reject(error)
                }
            }
        }
    }

    func search(keyword keyword: String, handler: (Result<[Song], NSError>) -> ()) {
        let request = Alamofire.request(.GET, "https://itunes.apple.com/search", parameters: ["term": keyword, "entity": "song", "limit": "\(limit)", "country": country])
        NetworkIndicator.sharedInstance.show()
        request.responseJSON { response in
            switch response.result {
            case .Success(let value):
                guard let JSON = value as? NSDictionary else {
                    handler(.Failure(NSError.errorWithAppError(.JSONParseFailed)))
                    return
                }
                guard let results = JSON["results"] as? [NSDictionary] else {
                    handler(.Success([]))
                    return
                }
                let songs = results.flatMap { (result) -> Song? in
                    return Song(result: result)
                }
                handler(.Success(songs))
            case .Failure(let error):
                handler(.Failure(error))
            }
        }
    }

    func search(keyword keyword: String) -> Promise<[Song]> {
        return Promise { (fulfill, reject) in
            search(keyword: keyword) { (result) -> () in
                switch result {
                case .Success(let songs):
                    fulfill(songs)
                case .Failure(let error):
                    reject(error)
                }
            }
        }
    }
}
