//
//  SongTest.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/11/22.
//  Copyright © 2015年 matsuosh. All rights reserved.
//

import XCTest
@testable import Dubbidson

class SongTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit() {
        guard
            let json = jsonFromFileName("topsongs.json") as? NSDictionary,
            let feed = json["feed"] as? NSDictionary,
            let entries = feed["entry"] as? [NSDictionary],
            let entry = entries.first else {
                XCTFail()
                return
        }
        guard let song = Song(topsongs: entry) else {
            XCTFail()
            return
        }
        XCTAssert(song.id == "1051394215")
        XCTAssert(song.name == "Hello")
        XCTAssert(song.artist == "Adele")
    }
    
    func jsonFromFileName(name: String) -> AnyObject? {
        if let path = NSBundle(forClass: self.classForCoder).pathForResource(name, ofType: nil) {
            if let data = NSData(contentsOfFile: path) {
                do {
                    return try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                } catch {
                    XCTFail((error as NSError).description)
                    return nil
                }
            }
        }
        XCTFail()
        return nil
    }


}
