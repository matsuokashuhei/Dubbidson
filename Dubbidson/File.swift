//
//  File.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/12/05.
//  Copyright © 2015年 matsuosh. All rights reserved.
//

enum Directory {

    case Documents
    case Caches
    case Temporary

    var URL: NSURL! {
        switch self {
        case .Documents:
            return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        case .Caches:
            return NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
        case .Temporary:
            return NSURL(fileURLWithPath: NSTemporaryDirectory())
        }
    }

}
