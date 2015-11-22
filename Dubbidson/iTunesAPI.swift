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
                    //return Song(entry: entry)
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


/*
public struct Song {

    public let id: String!
    public let name: String!
    public let imageURL: NSURL!
    public let artist: String!
    public let previewURL: NSURL!

    public var downloadFileURL: NSURL? {
        return FileIO.sharedInstance.downloadURL(self)
    }

    public init?(entry: NSDictionary) {
        if let id = entry["id"] as? NSDictionary, let idattributes = id["attributes"] as? NSDictionary, let imid = idattributes["im:id"] as? String,
           let imname = entry["im:name"] as? NSDictionary, let name = imname["label"] as? String,
           let images = entry["im:image"] as? [NSDictionary], let image = images.last, let imageURL = image["label"] as? String,
           let imartist = entry["im:artist"] as? NSDictionary, let artist = imartist["label"] as? String,
           let links = entry["link"] as? [NSDictionary], let link = links.last, let linkattributes = link["attributes"] as? NSDictionary, let previewURL = linkattributes["href"] as? String {
            self.id = imid
            self.name = name
            self.imageURL = NSURL(string: imageURL)!
            self.artist = artist
            self.previewURL = NSURL(string: previewURL)!
        } else {
            id = nil
            name = nil
            imageURL = nil
            artist = nil
            previewURL = nil
            return nil
        }
    }

    public init(id: String, name: String, imageURL: NSURL, artist: String, previewURL: NSURL) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.artist = artist
        self.previewURL = previewURL
    }

}

extension Song: Equatable {}
public func ==(lhs: Song, rhs: Song) -> Bool {
    return lhs.id == rhs.id
}
*/