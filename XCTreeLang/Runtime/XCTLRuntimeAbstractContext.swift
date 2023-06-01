//
//  XCTLRuntimeAbstractContext.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/25.
//

import Foundation

internal protocol XCTLRuntimeAbstractContext: AnyObject {
    
    var nativeObjectInstance: NSObject { get }
    
    func valueDefined(_ name: String) -> Bool
    func value(forName name: String) -> XCTLRuntimeVariable?
    func setValue(_ value: XCTLRuntimeVariable, forName name: String)
    func setValueToRoot(_ value: XCTLRuntimeVariable, forName name: String)
    
    func addImport(name: String)
    func addExport(name: String)
    
    func allocateObject(name: String, args: [XCTLRuntimeVariable]) throws -> XCTLRuntimeVariable
    func addLazyStatement(_ stmt: XCTLStatement)
    
    func makeSubContext() -> XCTLRuntimeAbstractContext
    
    func findConditionFrame() -> XCTLConditionParentStatementFrame?
    func findListFrame() -> XCTLListStatementFrame?
    func recordConditionFrame(_ frame: XCTLConditionParentStatementFrame?)
    func recordListFrame(_ frame: XCTLListStatementFrame?)
    
}
