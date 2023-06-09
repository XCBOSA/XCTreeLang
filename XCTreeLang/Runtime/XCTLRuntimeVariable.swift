//
//  XCTLRuntimeVariable.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

public class XCTLRuntimeVariable: NSObject {
    
    public var type: XCTLRuntimeVariableType
    public var rawValue: String
    public var rawObject: NSObject?
    public var rawFunction: (([XCTLRuntimeVariable]) throws -> XCTLRuntimeVariable)?
    
//    public var leftValue: XCTLRuntimeVariable?
//    public var leftValueMemberName: String?
    
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
    
    public class func variableFromSwiftAny(_ value: Any) throws -> XCTLRuntimeVariable {
        if value is NSNull {
            return .void
        }
        if let value = value as? String {
            return XCTLRuntimeVariable(type: .typeString, rawValue: value)
        }
        if let value = value as? Double {
            return XCTLRuntimeVariable(type: .typeNumber, rawValue: value.description)
        }
        if let value = value as? Bool {
            return XCTLRuntimeVariable(type: .typeBoolean, rawValue: value.description)
        }
        if let value = value as? NSObject {
            return XCTLRuntimeVariable(rawObject: value)
        }
        throw XCTLRuntimeError.callingTypeEncodingError
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
    
    public init(funcImpl: @escaping ([XCTLRuntimeVariable]) throws -> XCTLRuntimeVariable) {
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
    
    public func executeFunc(arg: [XCTLRuntimeVariable]) throws -> XCTLRuntimeVariable {
        return try self.rawFunction!(arg)
    }
    
}
