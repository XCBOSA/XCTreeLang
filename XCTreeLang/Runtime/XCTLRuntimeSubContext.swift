//
//  XCTLRuntimeSubContext.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/25.
//

import Foundation

internal class XCTLRuntimeSubContext: XCTLRuntimeAbstractContext {
    
    private let parent: XCTLRuntimeAbstractContext
    
    internal var nativeObjectInstance: NSObject {
        self.parent.nativeObjectInstance
    }
    
    private var values = [String : XCTLRuntimeVariable]()
    
    internal init(parent: XCTLRuntimeAbstractContext) {
        self.parent = parent
    }
    
    private var importNames = Set<String>()
    private var exportNames = Set<String>()
    
    internal func valueDefined(_ name: String) -> Bool {
        if self.values[name] != nil {
            return true
        }
        if self.importNames.contains(name) {
            return true
        }
        return self.parent.valueDefined(name)
    }
    
    internal func value(forName name: String) -> XCTLRuntimeVariable? {
        if name == "self" {
            return XCTLRuntimeVariable(rawObject: self.nativeObjectInstance)
        }
        if let value = self.values[name] {
            return value
        }
        if importNames.contains(name),
           let valueFromNative = self.nativeObjectInstance.value(forKey: name) as? NSObject {
            let object = XCTLRuntimeVariable(rawObject: valueFromNative)
            self.values[name] = object
            return object
        }
        return self.parent.value(forName: name)
    }
    
    internal func setValue(_ value: XCTLRuntimeVariable, forName name: String) {
        if self.exportNames.contains(name) {
            self.setValueToRoot(value, forName: name)
            return
        }
        if self.values[name] == nil {
            if self.valueDefined(name) {
                self.parent.setValue(value, forName: name)
                return
            }
        }
        self.values[name] = value
    }
    
    internal func setValueToRoot(_ value: XCTLRuntimeVariable, forName name: String) {
        self.parent.setValueToRoot(value, forName: name)
    }
    
    internal func setValueIgnoreParent(_ value: XCTLRuntimeVariable, forName name: String) {
        self.values[name] = value
    }
    
    internal func addImport(name: String) {
        self.importNames.insert(name)
    }
    
    internal func addExport(name: String) {
        self.exportNames.insert(name)
    }
    
    internal func allocateObject(name: String, args: [XCTLRuntimeVariable]) throws -> XCTLRuntimeVariable {
        return try self.parent.allocateObject(name: name, args: args)
    }
    
    internal func addLazyStatement(_ stmt: XCTLStatement) {
        self.parent.addLazyStatement(stmt)
    }
    
    internal func makeSubContext() -> XCTLRuntimeAbstractContext {
        return XCTLRuntimeSubContext(parent: self)
    }
    
    private var conditionFrame: XCTLConditionParentStatementFrame?
    private var listFrame: XCTLListStatementFrame?
    
    func findConditionFrame() -> XCTLConditionParentStatementFrame? {
        if let conditionFrame = self.conditionFrame {
            return conditionFrame
        }
        return self.parent.findConditionFrame()
    }
    
    func findListFrame() -> XCTLListStatementFrame? {
        if let listFrame = self.listFrame {
            return listFrame
        }
        return self.parent.findListFrame()
    }
    
    func recordListFrame(_ frame: XCTLListStatementFrame?) {
        self.listFrame = frame
    }
    
    func recordConditionFrame(_ frame: XCTLConditionParentStatementFrame?) {
        self.conditionFrame = frame
    }
    
}
