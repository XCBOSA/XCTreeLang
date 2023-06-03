//
//  XCTLVariableRefStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation
import XCTLRuntimeTypeInstanceModule

internal class XCTLVariableRefStatement: XCTLStatement, XCTLBackableStatement, XCTLExpressionPart {
    
    internal static let ignorePropertiesClass = [NSArray.self, NSDictionary.self]
    
    var type: XCTLStatementType { .typeVariableRef }
    
    var expressionValue: XCTLExpressionValue { .product }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var variableName: String = ""
    
    var nextVariableRefStmt: XCTLVariableRefStatement?
    
    weak var parent: XCTLStatement?
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        if try lex.next().type == .typeIdentifier {
            return XCTLVariableRefStatement()
        }
        return nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
//        try lex.next()
        let value = try lex.next()
        self.variableName = value.rawValue
        
        let point = try lex.peek()
        if point.type == .typePoint {
            try lex.next()
            self.nextVariableRefStmt = XCTLVariableRefStatement()
            try self.nextVariableRefStmt?.parseStatement(fromLexerToSelf: lex, fromParent: fromParent)
        }
        
        lex.lastStatement = self
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        guard let value = context.value(forName: variableName) else {
            throw XCTLRuntimeError.undefinedVariable(variableName: variableName)
        }
        var nextMemberStmt = self.nextVariableRefStmt
        var currentValue = value
        var refName = self.variableName
        while let nextStmt = nextMemberStmt {
            let memberName = nextStmt.variableName
            refName.append(".")
            refName.append(memberName)
            if currentValue.type != .typeObject {
                throw XCTLRuntimeError.unknownMemberForVariable(memberName: memberName, variableName: refName)
            }
            let rawObject = currentValue.objectValue
            
            var obj: Any?
            let exception = ocTryCatch {
                obj = rawObject.value(forKey: memberName)
            }
            if exception != nil || Self.ignorePropertiesClass.contains(where: { rawObject.isKind(of: $0) }) {
                if nextStmt.nextVariableRefStmt == nil {
                    if let array = rawObject as? NSArray {
                        switch memberName {
                        case "count":
                            let returnValue = XCTLRuntimeVariable(type: .typeNumber, rawValue: array.count.description)
                            context.variableStack.pushVariable(returnValue)
                            return returnValue
                        default:
                            break
                        }
                    }
                    let selector = NSSelectorFromString(memberName)
                    if rawObject.responds(to: selector) {
                        let funcIntrinsicVariable = XCTLRuntimeVariable { args in
                            let invocation = XCTLSwiftInvocation(target: rawObject, selector: selector)
                            let value = try invocation.invokeMemberFunc(params: args.map({ $0.nativeValue }))
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
                        context.variableStack.pushVariable(funcIntrinsicVariable)
                        return funcIntrinsicVariable
                    }
                }
                throw XCTLRuntimeError.unknownMemberForVariable(memberName: memberName, variableName: refName)
            }
            guard let obj = obj as? NSObject else {
                throw XCTLRuntimeError.unknownMemberForVariable(memberName: memberName, variableName: refName)
            }
            let newValue = XCTLRuntimeVariable(rawObject: obj)
//            newValue.leftValue = currentValue
//            newValue.leftValueMemberName = memberName
            currentValue = newValue
            nextMemberStmt = nextStmt.nextVariableRefStmt
        }
        context.variableStack.pushVariable(currentValue)
        return currentValue
    }
    
    func evaluateBack(_ valueToBack: XCTLRuntimeVariable, inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        guard let value = context.value(forName: variableName) else {
            throw XCTLRuntimeError.undefinedVariable(variableName: variableName)
        }
        var nextMemberStmt = self.nextVariableRefStmt
        var currentValue = value
        var refName = self.variableName
        
        if nextMemberStmt == nil {
            context.setValue(valueToBack, forName: self.variableName)
        }
        while let nextStmt = nextMemberStmt {
            let memberName = nextStmt.variableName
            refName.append(".")
            refName.append(memberName)
            if currentValue.type != .typeObject {
                throw XCTLRuntimeError.unknownMemberForVariable(memberName: memberName, variableName: refName)
            }
            let rawObject = currentValue.objectValue
            
            if nextStmt.nextVariableRefStmt == nil {
                rawObject.setValue(valueToBack.nativeValue, forKey: memberName)
                break
            }
            
            var obj: Any?
            let exception = ocTryCatch {
                obj = rawObject.value(forKey: memberName)
            }
            if exception != nil {
                throw XCTLRuntimeError.unknownMemberForVariable(memberName: memberName, variableName: refName)
            }
            guard let obj = obj as? NSObject else {
                throw XCTLRuntimeError.unknownMemberForVariable(memberName: memberName, variableName: refName)
            }
            
            let newValue = XCTLRuntimeVariable(rawObject: obj)
//            newValue.leftValue = currentValue
//            newValue.leftValueMemberName = memberName
            currentValue = newValue
            nextMemberStmt = nextStmt.nextVariableRefStmt
        }
        return valueToBack
    }
    
}
