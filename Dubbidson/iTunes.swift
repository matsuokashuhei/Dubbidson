//
//  Music.swift
//  Dubski
//
//  Created by matsuosh on 2015/08/16.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

import Alamofire
import Box
import PromiseKit
import Result

class iTunes {

    static let sharedInstance = iTunes()

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

    func configure(#limit: Int, country: String) {
        self.limit = limit
        self.country = country
    }

    func topsongs(#handler: (Result<[Song], NSError>) -> ()) {
        let URL = NSURL(string: "https://itunes.apple.com/\(country)/rss/topsongs/limit=\(limit)/explicit=true/json")!
        let request = Alamofire.request(.GET, URL, parameters: nil)
        debugPrintln(request)
        NetworkIndicator.sharedInstance.show()
        request.responseJSON() { (_, _, object, error) in
            NetworkIndicator.sharedInstance.dismiss()
            if let error = error {
                handler(.Failure(Box(error)))
                return
            }
            if let json = object as? NSDictionary, let feed = json["feed"] as? NSDictionary, let entries = feed["entry"] as? [NSDictionary] {
                let songs = entries.flatMap { (entry) -> [Song] in
                    if let song = Song(entry: entry) {
                        return [song]
                    } else {
                        return []
                    }

                }
                handler(.Success(Box(songs)))
            } else {
                handler(.Failure(Box(NSError())))
            }
        }
    }

    func topsongs() -> Promise<[Song]> {
        return Promise { (fulfill, reject) in
            topsongs { (result) -> () in
                switch result {
                case .Success(let box):
                    fulfill(box.value)
                case .Failure(let box):
                    reject(box.value)
                }
            }
        }
    }

    func search(#keyword: String, handler: (Result<[Song], NSError>) -> ()) {
        let URL = NSURL(string: "https://itunes.apple.com/search")!
        let request = Alamofire.request(.GET, "https://itunes.apple.com/search", parameters: ["term": keyword, "entity": "song", "limit": "\(limit)", "country": country])
        debugPrintln(request)
        NetworkIndicator.sharedInstance.show()
        request.responseJSON { (_, _, object, error) in
            NetworkIndicator.sharedInstance.dismiss()
            if let error = error {
                handler(.Failure(Box(error)))
                return
            }
            if let json = object as? NSDictionary, let results = json["results"] as? [NSDictionary] {
                let songs = results.flatMap { (result) -> [Song] in
                    if let id = result["trackId"] as? Int,
                       let artist = result["artistName"] as? String,
                       let name = result["trackName"] as? String,
                       let imageURLString = result["artworkUrl100"] as? String,
                       let previewURLString = result["previewUrl"] as? String,
                       let imageURL = NSURL(string: imageURLString),
                       let previewURL = NSURL(string: previewURLString) {
                        return [Song(id: "\(id)", name: name, imageURL: imageURL, artist: artist, previewURL: previewURL)]
                    } else {
                        return []
                    }
                }
                handler(.Success(Box(songs)))
            } else {
                handler(.Success(Box([])))
            }
        }
    }

    func search(#keyword: String) -> Promise<[Song]> {
        return Promise { (fulfill, reject) in
            search(keyword: keyword) { (result) -> () in
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


public struct Song {

    public let id: String!
    public let name: String!
    public let imageURL: NSURL!
    public let artist: String!
    public let previewURL: NSURL!

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