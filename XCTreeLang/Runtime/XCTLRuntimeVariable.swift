//
//  XCTLRuntimeVariable.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

public class XCTLRuntimeVariable {
    
    public var type: XCTLRuntimeVariableType
    public var rawValue: String
    public var rawObject: NSObject?
    public var rawFunction: (([XCTLRuntimeVariable]) -> XCTLRuntimeVariable)?
    
    internal weak var rawFunctionStatement: XCTLStatement?
    
    public func toString() -> String {
        if type == .typeFuncImpl || type == .typeFuncIntrinsic {
            return "Function"
        }
        if type == .typeObject {
            return self.rawObject?.description ?? ""
        }
        return self.rawValue
    }
    
    public init(type: XCTLRuntimeVariableType, rawValue: String) {
        self.type = type
        self.rawValue = rawValue
        self.rawObject = nil
        self.rawFunction = nil
    }
    
    public init(rawObject: NSObject) {
        self.type = .typeObject
        self.rawValue = ""
        self.rawObject = rawObject
        self.rawFunction = nil
    }
    
    public init(funcImpl: @escaping ([XCTLRuntimeVariable]) -> XCTLRuntimeVariable) {
        self.type = .typeFuncIntrinsic
        self.rawValue = ""
        self.rawObject = nil
        self.rawFunction = funcImpl
    }
    
    internal init(funcImplStmt: XCTLStatement) {
        self.type = .typeFuncImpl
        self.rawValue = ""
        self.rawObject = nil
        self.rawFunction = nil
        self.rawFunctionStatement = funcImplStmt
    }
    
    public var stringValue: String {
        return self.rawValue
    }
    
    public var intValue: Int {
        return Int(self.rawValue)!
    }
    
    public var doubleValue: Double {
        return Double(self.rawValue)!
    }
    
    public var boolValue: Bool {
        return Bool(self.rawValue)!
    }
    
    public var objectValue: NSObject {
        return self.rawObject!
    }
    
    public static var void: XCTLRuntimeVariable {
        return XCTLRuntimeVariable(type: .typeVoid, rawValue: "")
    }
    
    public var nativeValue: Any {
        switch self.type {
        case .typeVoid:
            return NSNull()
        case .typeObject:
            return self.objectValue
        case .typeString:
            return self.stringValue
        case .typeNumber:
            return self.doubleValue
        case .typeBoolean:
            return self.boolValue
        case .typeFuncIntrinsic:
            return self.rawFunction ?? NSNull()
        case .typeFuncImpl:
            return NSNull()
        }
    }
    
    public func executeFunc(arg: [XCTLRuntimeVariable]) -> XCTLRuntimeVariable {
        return self.rawFunction!(arg)
    }
    
}
