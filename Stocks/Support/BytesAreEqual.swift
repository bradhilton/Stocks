//
//  BytesAreEqual.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/13/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import Darwin

func bytesAreEqual<T>(_ a: T, _ b: T) -> Bool {
    withUnsafePointer(to: a) { a in
        withUnsafePointer(to: b) { b in
            memcmp(UnsafeRawPointer(a), UnsafeRawPointer(b), MemoryLayout<T>.size) == 0
        }
    }
}
