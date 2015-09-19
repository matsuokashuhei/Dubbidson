//
//  ATResult.swift
//  Dubbidson
//
//  Created by matsuosh on 2015/09/14.
//  Copyright © 2015年 matsuosh. All rights reserved.
//

import Foundation
import Result

// TO-DO: As soon as https://github.com/antitypical/Result/issues/77 is resolved, this file should be removed
struct ATResult<T, Error : ErrorType> {
    typealias t = Result<T, Error>
}
