//
//  Platform.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/11/30.
//  Copyright © 2015年 matsuosh. All rights reserved.
//

struct Platform {

    static let isSimulator: Bool = {
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
    }()

    static let isDevice: Bool = {
        return isSimulator == false
    }()
}