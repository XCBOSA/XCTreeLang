//
//  XCTLRange.swift
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/1.
//

import Foundation

public class XCTLRange: NSObject, XCTLEnumerator {
    
    public var begin: Double
    public var length: Double
    public var step: Double
    public var current: Double
    
    public init(begin: Double, length: Double, step: Double) {
        self.begin = begin
        self.length = length
        self.step = step
        self.current = begin
    }
    
    public func moveNext() -> XCTLRuntimeVariable {
        let value = self.current
        if value >= begin + length {
            return .void
        }
        self.current += step
        return XCTLRuntimeVariable(type: .typeNumber, rawValue: value.description)
    }
    
}
