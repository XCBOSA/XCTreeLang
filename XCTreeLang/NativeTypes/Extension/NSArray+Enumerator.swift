//
//  Range.swift
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/3.
//

import Foundation

public class NSArrayTLEnumerator: XCTLEnumerator {
    
    public var array: NSArray
    
    private var index = 0
    
    public init(array: NSArray) {
        self.array = array
    }
    
    public func moveNext() -> XCTLRuntimeVariable {
        if self.index < self.array.count {
            if let value = self.array[index] as? NSObject {
                self.index += 1
                return XCTLRuntimeVariable(rawObject: value)
            }
            self.index += 1
            return moveNext()
        }
        return .void
    }
    
}

extension NSArray: XCTLEnumeratorProvider {
    
    public func provideEnumerator() -> XCTLEnumerator {
        return NSArrayTLEnumerator(array: self)
    }
    
}
