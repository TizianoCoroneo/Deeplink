//
//  URL+initWithStringLiteral.swift
//  
//
//  Created by Tiziano Coroneo on 29/02/2020.
//

import Foundation

extension URL: ExpressibleByStringLiteral {
    public typealias StringLiteralType = StaticString

    public init(
        stringLiteral value: StaticString
    ) {
        self.init(string: value
            .withUTF8Buffer { String(decoding: $0, as: UTF8.self) })!
    }
}
