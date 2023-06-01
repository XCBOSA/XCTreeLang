//
//  XCTLStream.swift
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/1.
//

import Foundation

@objc
public protocol XCTLStreamDelegate: NSObjectProtocol {
    
    func stream(_ stream: XCTLStream, appendText text: String)
    
}

@objcMembers
public class XCTLStream: NSObject {
    
    public init(onAppendBlock: @escaping (String) -> Void) {
        self.onAppendBlock = onAppendBlock
        super.init()
    }
    
    public weak var delegate: XCTLStreamDelegate?
    private let onAppendBlock: (String) -> Void
    
    public func append(text: String) {
        self.onAppendBlock(text)
        self.delegate?.stream(self, appendText: text)
    }
    
}
