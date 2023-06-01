//
//  XCTLGenerateProtocol.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

@objc
public protocol XCTLGenerateProtocol {
    
    static func initWithXCT(_ arg: [Any]) throws -> NSObject
    
}
