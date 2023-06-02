//
//  XCTLEqualthanStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/25.
//

import Foundation

internal class XCTLEqualthanStatement : XCTLStatement {
    
    var type: XCTLStatementType { .typeEqualthan }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var compareValueStmt: XCTLStatement!
    var childrenStmt: XCTLStatement = XCTLListStatement()
    
    weak var parent: XCTLStatement?
    weak var condStmt: XCTLConditionParentStatement?
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        if try lex.next().type == .typeEqualthan {
            return XCTLEqualthanStatement()
        }
        return nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        guard let parent = fromParent as? XCTLListStatementProtocol,
              let condStmt = parent.conditionParent else {
            throw XCTLCompileTimeError.unexpectParentStatementType(expect: "any-cond-stmt", butGot: "\(fromParent?.type.rawValue ?? "void")")
        }
        self.parent = fromParent
        self.condStmt = condStmt
        try lex.next()
        self.compareValueStmt = try self.parseNextExpression(forLexer: lex, terminator: .typeOpenBrace)
        try self.childrenStmt.parseStatement(fromLexerToSelf: lex, fromParent: self)
        
        lex.lastStatement = self
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        guard let condFrame = context.findConditionFrame() else {
            throw XCTLRuntimeError.invalidConditionFrame
        }
        
        guard let originalValue = self.parent?.holdingObject,
              originalValue.type != .typeVoid else {
            throw XCTLRuntimeError.parentNoHoldingObject
        }
        
        if condFrame.doNext {
            condFrame.doNext = false
            condFrame.doElse = false
            return try self.childrenStmt.evaluate(inContext: context)
        }
        
        let compareValue = try self.compareValueStmt.evaluate(inContext: context)
        if compareValue.type == .typeVoid {
            throw XCTLRuntimeError.unexpectedVariableType(expect: "any", butGot: "void")
        }
        
        var equalTo = false
        if let compareValueNSObject = compareValue.nativeValue as? NSObject,
           let originalValueNSObject = originalValue.nativeValue as? NSObject {
            equalTo = compareValueNSObject == originalValueNSObject
        }
        
        if equalTo {
            condFrame.doElse = false
            return try self.childrenStmt.evaluate(inContext: context)
        }
        
        return .void
    }
    
}
