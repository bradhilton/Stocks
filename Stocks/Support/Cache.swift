//
//  Cache.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/14/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import Foundation

func cachedResult<T, U>(for args: T, _ computeResult: (T) -> U) -> U {
    let cacheKey = CacheKey(args)
    if let result = cache.object(forKey: cacheKey)?.value as? U {
        return result
    } else {
        let result = computeResult(args)
        cache.setObject(CacheValue(value: result), forKey: cacheKey)
        return result
    }
}

private class CacheKey : NSObject {
    
    let bytes: [UInt8]
    
    init<T>(_ key: T) {
        self.bytes = withUnsafeBytes(of: key, Array.init)
    }
    
    override var hash: Int {
        bytes.hashValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? CacheKey else { return false }
        return bytes == object.bytes
    }
    
}

private class CacheValue {
    let value: Any
    init(value: Any) {
        self.value = value
    }
}

private let cache = NSCache<CacheKey, CacheValue>()
