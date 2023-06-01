//
//  XCTLToken.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

internal class XCTLToken {
    
    internal var type: XCTLTokenType
    internal var rawValue: String
    
    internal init(type: XCTLTokenType, rawValue: String) {
        self.type = type
        self.rawValue = rawValue
    }
    
    internal static var eof: XCTLToken {
        return XCTLToken(type: .typeEOF, rawValue: "")
    }
    
}
