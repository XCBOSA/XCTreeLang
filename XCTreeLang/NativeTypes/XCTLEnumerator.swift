//
//  XCTLEnumerator.swift
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/1.
//

import Foundation

public protocol XCTLEnumerator {
    
    func moveNext() -> XCTLRuntimeVariable
    
}
