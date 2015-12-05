//
//  Movie.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/11/24.
//  Copyright © 2015年 matsuosh. All rights reserved.
//

import RealmSwift

class Movie: Object {

    dynamic var id = ""
    //dynamic var fileName = ""
    dynamic var thumnailData: NSData? = nil
    dynamic var song: Song? = nil

    override static func primaryKey() -> String? {
        return "id"
    }

    func save() {
        DB.sharedInstance.save(self)
    }
}
