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
        do {
            guard
                let json = jsonFromFileName("topsongs.json") as? NSDictionary,
                let feed = json["feed"] as? NSDictionary,
                let entries = feed["entry"] as? [NSDictionary],
                let entry = entries.first else {
                    XCTFail()
                    return
            }
            guard let song = Song(entry: entry) else {
                XCTFail()
                return
            }
            XCTAssert(song.id == "1051394215")
            XCTAssert(song.name == "Hello")
            XCTAssert(song.artist == "Adele")
            XCTAssert(song.artworkURL == NSURL(string: "http://is1.mzstatic.com/image/thumb/Music6/v4/49/05/0a/49050af2-82dd-1a7c-547d-c7fda91ba271/886445568219.jpg/170x170bb-85.jpg")!)
            XCTAssert(song.previewURL == NSURL(string: "http://a1912.phobos.apple.com/us/r1000/170/Music6/v4/68/34/f1/6834f1f8-8fdb-4247-492a-c0caea580082/mzaf_3920281300599106672.plus.aac.p.m4a")!)
            XCTAssertNil(song.audioFileURL)
        }
        do {
            guard
                let json = jsonFromFileName("search.json") as? NSDictionary,
                let results = json["results"] as? [NSDictionary],
                let result = results.first else {
                    XCTFail()
                    return
                }
            guard let song = Song(result: result) else {
                XCTFail()
                return
            }
            XCTAssert(song.id == "32186387")
            XCTAssert(song.name == "Numb / Encore")
            XCTAssert(song.artist == "Linkin Park & Jay-Z")
            //XCTAssert(song.artworkURLString == "http://is2.mzstatic.com/image/thumb/Music/v4/3f/6e/4a/3f6e4ae4-298f-6295-18a9-7559d3c6109f/source/100x100bb.jpg")
            XCTAssert(song.artworkURL == NSURL(string: "http://is2.mzstatic.com/image/thumb/Music/v4/3f/6e/4a/3f6e4ae4-298f-6295-18a9-7559d3c6109f/source/100x100bb.jpg")!)
            //XCTAssert(song.previewURLString == "http://a1784.phobos.apple.com/us/r1000/080/Music/60/31/b3/mzm.agqwrzfv.aac.p.m4a")
            XCTAssert(song.previewURL == NSURL(string: "http://a1784.phobos.apple.com/us/r1000/080/Music/60/31/b3/mzm.agqwrzfv.aac.p.m4a")!)
            XCTAssertNil(song.audioFileURL)
        }
        
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
