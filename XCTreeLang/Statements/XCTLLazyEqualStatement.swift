//
//  XCTLLazyEqualStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

internal class XCTLLazyEqualStatement: XCTLStatement {
    
    var type: XCTLStatementType { .typeLazyEqual }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var leftStatement = XCTLVariableRefStatement()
    var equalToStatement: XCTLStatement = XCTLImmediateStatement()
    
    weak var parent: XCTLStatement?
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        if try lex.next().type == .typePoint {
            return XCTLLazyEqualStatement()
        }
        return nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        guard let parent = self.parent as? XCTLInitStatement else {
            throw XCTLCompileTimeError.unexpectParentStatementType(expect: "value", butGot: "got lazy nothing")
        }
        try lex.next()
        
        let leftStmtWithOutParent = XCTLVariableRefStatement()
        try leftStmtWithOutParent.parseStatement(fromLexerToSelf: lex, fromParent: fromParent)
        self.leftStatement.parent = self
        self.leftStatement.nextVariableRefStmt = leftStmtWithOutParent
        self.leftStatement.variableName = parent.defineName
        
        let equalToken = try lex.next()
        if equalToken.type != .typeEqual {
            throw XCTLCompileTimeError.unexpectTokenInStatement(expect: XCTLTokenType.typeEqual.rawValue, butGot: equalToken.type.rawValue)
        }
        self.equalToStatement = try self.parseNextExpression(forLexer: lex)
        
        lex.lastStatement = self
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        let rightValue = try equalToStatement.evaluate(inContext: context)
        return try self.leftStatement.evaluateBack(rightValue, inContext: context)
    }
    
}

