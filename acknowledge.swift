#!/usr/bin/env xcrun swift -F Carthage/Build/Mac

import Foundation
import Markingbird

protocol Streamable {
    var title: String { get }
    var body: String { get }
}

extension Streamable {
    var writableString: String {
        return "# \(title)\n\n\(body)"
    }
}

struct License: Streamable {
    let libraryName: String
    let legalText: String

    var title: String {
        return libraryName
    }

    var body: String {
        return legalText
    }
}

func getLicense(URL: NSURL) throws -> License {
    let legalText = try String(contentsOfURL: URL, encoding: NSUTF8StringEncoding)
    let pathComponents = URL.pathComponents!
    print("pathComponents: \(pathComponents)")
    let libraryName = pathComponents[pathComponents.count - 2]
    return License(libraryName: libraryName, legalText: legalText)
}

func run() throws {

    let cocoaPodsDir = "Pods/"
    let carthageDir = "Carthage/Checkouts/"
    //let outputFile = "Venmo/Resources/LICENSES.html"
    let outputFile = "Dubbidson/LICENSES.html"
    let options: NSDirectoryEnumerationOptions = [.SkipsPackageDescendants, .SkipsHiddenFiles]

    let fileManager = NSFileManager.defaultManager()


    // Get URL’s for all files in cocoaPodsDir and carthageDir

    guard
        let cocoaPodsDirURL = NSURL(string: cocoaPodsDir),
        let cocoaPodsEnumerator = fileManager.enumeratorAtURL(cocoaPodsDirURL, includingPropertiesForKeys: nil, options: options, errorHandler: nil)
    else {
        print("Error: \(cocoaPodsDir) directory not found. Please run `rake`")
        return
    }

    guard
        let carthageDirURL = NSURL(string: carthageDir),
        let carthageEnumerator = fileManager.enumeratorAtURL(carthageDirURL, includingPropertiesForKeys: nil, options: options, errorHandler: nil)
    else {
        print("Error: \(carthageDir) directory not found. Please run `rake`")
        return
    }

    guard
        let cocoaPodsURLs = cocoaPodsEnumerator.allObjects as? [NSURL],
        let carthageURLs = carthageEnumerator.allObjects as? [NSURL]
    else {
        print("Unexpected error: Enumerator contained item that is not NSURL.")
        return
    }

    let allURLs = cocoaPodsURLs + carthageURLs

    // Get just the LICENSE files and convert them to License structs

    let licenseURLs = allURLs.filter { URL in
        return URL.lastPathComponent?.rangeOfString("LICENSE") != nil
        || URL.lastPathComponent?.rangeOfString("LICENCE") != nil
        || URL.lastPathComponent?.rangeOfString("license") != nil
        || URL.lastPathComponent?.rangeOfString("licence") != nil
    }
    /*
    let outputFile = "Dubbidson/LICENSES.html"
    let licenseURLs = [
        NSURL(string: "/Users/matsuosh/Documents/iOS/Dubbidson/Carthage/Checkouts/Alamofire/LICENSE")!,
        NSURL(string: "/Users/matsuosh/Documents/iOS/Dubbidson/Carthage/Checkouts/AlamofireImage/LICENSE")!,
        NSURL(string: "/Users/matsuosh/Documents/iOS/Dubbidson/Carthage/Checkouts/Async/LICENSE.txt")!,
        NSURL(string: "/Users/matsuosh/Documents/iOS/Dubbidson/Carthage/Checkouts/Chameleon/LICENSE.md")!,
        NSURL(string: "/Users/matsuosh/Documents/iOS/Dubbidson/Carthage/Checkouts/CleanroomASL/LICENSE")!,
        NSURL(string: "/Users/matsuosh/Documents/iOS/Dubbidson/Carthage/Checkouts/CleanroomLogger/LICENSE")!,
        NSURL(string: "/Users/matsuosh/Documents/iOS/Dubbidson/Carthage/Checkouts/NVActivityIndicatorView/LICENSE")!,
        NSURL(string: "/Users/matsuosh/Documents/iOS/Dubbidson/Carthage/Checkouts/Result/LICENSE")!,
        NSURL(string: "/Users/matsuosh/Documents/iOS/Dubbidson/Carthage/Checkouts/RxSwift/LICENSE.md")!,
        NSURL(string: "/Users/matsuosh/Documents/iOS/Dubbidson/Carthage/Checkouts/SVProgressHUD/LICENSE.txt")!,
        NSURL(string: "/Users/matsuosh/Documents/iOS/Dubbidson/Carthage/Checkouts/XCGLogger/LICENSE.txt")!,
    ]
    */

    let licenses = licenseURLs.flatMap { try? getLicense($0) }


    // Write each License into outputFile after converting them to HTML using Markingbird

    var markdown = Markdown()
    let html = licenses.map { markdown.transform($0.writableString) }.joinWithSeparator("\n")

    try html.writeToFile(outputFile, atomically: false, encoding: NSUTF8StringEncoding)
}

func main() {
    do {
        try run()
    } catch let error as NSError {
        print(error.localizedDescription)
    }
}

main()
