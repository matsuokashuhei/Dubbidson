//
//  Song.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/11/22.
//  Copyright © 2015年 matsuosh. All rights reserved.
//

import UIKit
import RealmSwift

class Song: Object {
    
    dynamic var id = ""
    dynamic var name = ""
    dynamic var artworkURLString = ""
    dynamic var artworkData: NSData? = nil
    dynamic var artist = ""
    dynamic var previewURLString = ""
    dynamic var audioFileURLString = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init?(topsongs entry: NSDictionary) {
        self.init()
        guard let id = entry["id"] as? NSDictionary,
            let idattributes = id["attributes"] as? NSDictionary,
            let imid = idattributes["im:id"] as? String else {
                return nil
        }
        self.id = imid
        guard let imname = entry["im:name"] as? NSDictionary,
            let name = imname["label"] as? String else {
                return nil
        }
        self.name = name
        guard let images = entry["im:image"] as? [NSDictionary],
            let image = images.last,
            let imageURL = image["label"] as? String else {
                return nil
        }
        self.artworkURLString = imageURL
        guard let imartist = entry["im:artist"] as? NSDictionary,
            let artist = imartist["label"] as? String else {
                return nil
        }
        self.artist = artist
        guard
            let links = entry["link"] as? [NSDictionary],
            let link = links.last,
            let linkattributes = link["attributes"] as? NSDictionary,
            let previewURL = linkattributes["href"] as? String else {
                return nil
        }
        self.previewURLString = previewURL
    }
    
    convenience init?(search entry: NSDictionary) {
        self.init()
        guard
            let trackId = entry["trackId"] as? Int,
            let artistName = entry["artistName"] as? String,
            let trackName = entry["trackName"] as? String,
            let artworkURL = entry["artworkUrl100"] as? String,
            let previewURL = entry["previewUrl"] as? String else {
                return nil
        }
        id = "\(trackId)"
        name = trackName
        artist = artistName
        artworkURLString = artworkURL
        previewURLString = previewURL
    }
    
    var artworkURL: NSURL {
        return NSURL(string: artworkURLString)!
    }
    
    var artwork: UIImage? {
        guard let data = artworkData else {
            return nil
        }
        return UIImage(data: data)
    }
    
    var previewURL: NSURL {
        return NSURL(string: previewURLString)!
    }
    
    var audioFileURL: NSURL? {
        if NSFileManager().fileExistsAtPath(audioFileURLString) {
            return NSURL(string: audioFileURLString)!
        }
        return nil
    }
}
