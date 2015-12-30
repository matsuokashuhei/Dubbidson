//
//  DB.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/11/24.
//  Copyright © 2015年 matsuosh. All rights reserved.
//

import Async
import RealmSwift
//import CleanroomLogger
import XCGLogger

class DB {
    
    let logger = XCGLogger.defaultInstance()

    func clear() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.objects(Song).forEach { song in
                    if song.videos.count == 0 {
                        logger.verbose("realm.delete(\(song))")
                        realm.delete(song)
                    }
                }
            }
        } catch let error as NSError {
            logger.error(error.description)
        }
    }

    static let sharedInstance = DB()

    func save(object: Object) {
        Async.main {
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(object, update: true)
                }
            } catch let error as NSError {
                self.logger.error(error.description)
            }
        }
    }

    func delete(object: Object) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(object)
            }
        } catch let error as NSError {
            //Log.error?.message(error.description)
            logger.error(error.description)
        }
    }

    func delete(objects: [Object]) {
        objects.forEach { delete($0) }
    }
    /*
    func all<T: Object>(type: T.Type) -> [T] {
        do {
            let realm = try Realm()
            return realm.objects(type)
        } catch let error as NSError {
            Log.error?.message(error.description)
            retrun []
        }
    }
    */


}