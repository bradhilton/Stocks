//
//  Function.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/14/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

protocol Function {
    associatedtype Args
    associatedtype Result
    func callAsFunction(_ args: Args) -> Result
}
