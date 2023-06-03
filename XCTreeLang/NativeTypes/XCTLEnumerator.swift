//
//  XCTLEnumerator.swift
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/1.
//

import Foundation

@objc
public protocol XCTLEnumerator {
    
    func moveNext() -> XCTLRuntimeVariable
    
}

@objc
public protocol XCTLEnumeratorProvider {
    
    func provideEnumerator() -> XCTLEnumerator
    
}
