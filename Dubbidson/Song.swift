//
//  Song.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/11/22.
//  Copyright © 2015年 matsuosh. All rights reserved.
//

import UIKit

import Alamofire
import AlamofireImage
import RealmSwift

public class Song: Object {

    dynamic var id = ""
    dynamic var name = ""
    dynamic var artworkURLString = ""
    dynamic var artworkData: NSData? = nil
    dynamic var artist = ""
    dynamic var previewURLString = ""
    dynamic var audioFileURLString = ""
    
    override public var description: String {
        return "id: \(id), name: \(name), artist: \(artist)"
    }

    override public static func primaryKey() -> String? {
        return "id"
    }

    var videos: [Video] {
        return linkingObjects(Video.self, forProperty: "song")
    }
    
    convenience init?(entry item: NSDictionary) {
        self.init()
        guard let id = item["id"] as? NSDictionary,
            let idattributes = id["attributes"] as? NSDictionary,
            let imid = idattributes["im:id"] as? String else {
                return nil
        }
        self.id = imid
        guard let imname = item["im:name"] as? NSDictionary,
            let name = imname["label"] as? String else {
                return nil
        }
        self.name = name
        guard let images = item["im:image"] as? [NSDictionary],
            let image = images.last,
            let imageURL = image["label"] as? String else {
                return nil
        }
        self.artworkURLString = imageURL
        guard let imartist = item["im:artist"] as? NSDictionary,
            let artist = imartist["label"] as? String else {
                return nil
        }
        self.artist = artist
        guard
            let links = item["link"] as? [NSDictionary],
            let link = links.last,
            let linkattributes = link["attributes"] as? NSDictionary,
            let previewURL = linkattributes["href"] as? String else {
                return nil
        }
        self.previewURLString = previewURL
    }

    convenience init?(result item: NSDictionary) {
        self.init()
        guard
            let trackId = item["trackId"] as? Int,
            let artistName = item["artistName"] as? String,
            let trackName = item["trackName"] as? String,
            let artworkURL = item["artworkUrl100"] as? String,
            let previewURL = item["previewUrl"] as? String else {
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
        if let data = artworkData {
            return UIImage(data: data)
        } else {
            return nil
        }
    }

    var previewURL: NSURL {
        return NSURL(string: previewURLString)!
    }

    var audioFileURL: NSURL? {
        // TODO: ファイルの管理を整理する
        guard let lastPathComponent = previewURL.lastPathComponent else {
            return nil
        }
        if #available(iOS 9, *) {
            return NSURL(fileURLWithPath: lastPathComponent, isDirectory: false, relativeToURL: Directory.Temporary.URL)
        } else {
            return NSURL(string: lastPathComponent, relativeToURL: Directory.Temporary.URL)
        }
    }

    func save() {
        DB.sharedInstance.save(self)
    }

}

extension Song: Equatable {}
public func ==(lhs: Song, rhs: Song) -> Bool {
    return lhs.id == rhs.id
}
