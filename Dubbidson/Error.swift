//
//  Error.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/23.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

class Error {

    class func unknown() -> NSError {
        return create(code: -999, localizedDescription: "An unknown error has occurred.")
    }

    class func create(#code: Int, localizedDescription: String) -> NSError {
        return NSError(domain: "DubbidsonErrorDomain", code: code, userInfo: ["NSLocalizedDescriptionKey": localizedDescription])
    }
}
