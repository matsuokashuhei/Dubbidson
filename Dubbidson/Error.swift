//
//  Error.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/08/23.
//  Copyright (c) 2015年 matsuosh. All rights reserved.
//

import Foundation

/*
class Error {

    class func unknown() -> NSError {
        return create(code: -999, localizedDescription: "An unknown error has occurred.")
    }

    class func create(code code: Int, localizedDescription: String) -> NSError {
        return NSError(domain: "DubbidsonErrorDomain", code: code, userInfo: ["NSLocalizedDescriptionKey": localizedDescription])
    }
}
*/

extension NSError {
    
    class func errorWithAppError(error: AppError) -> NSError {
        return NSError(domain: "DubbidsonErrorDomain", code: 999999, userInfo: ["description": error.description])
    }
}

enum AppError: ErrorType {
    case OptionalValueIsNone
    case UIImagePNGRepresentationIsFailed
    case Unknown
    case JSONParseFailed
}

extension AppError: CustomStringConvertible {
    var description: String {
        switch self {
        case .OptionalValueIsNone:
            return "Optional value is none"
        case .UIImagePNGRepresentationIsFailed:
            return "UIImagePNGRepresentation is failed"
        case .JSONParseFailed:
            return "JSON parse failed"
        case .Unknown:
            return "An unknown error occurred"
        }
    }
}