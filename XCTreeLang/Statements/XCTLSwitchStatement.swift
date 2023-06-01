//
//  XCTLSwitchStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/25.
//

import Foundation

internal class XCTLSwitchStatement: XCTLStatement, XCTLConditionParentStatement {
    
    var type: XCTLStatementType { .typeSwitch }
    
    var holdingObject: XCTLRuntimeVariable = .void
    
    var switchingObjectStmt: XCTLStatement!
    var childrenStmt: XCTLStatement = XCTLListStatement()
    
    var doElse: Bool = true
    
    var doNext: Bool = false
    
    weak var parent: XCTLStatement?
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        if try lex.next().type == .typeSwitch {
            return XCTLSwitchStatement()
        }
        return nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        try lex.next()
        self.switchingObjectStmt = try self.parseNextStatement(forLexer: lex, prototypes: XCTLExpressionPrototypes)
        try self.childrenStmt.parseStatement(fromLexerToSelf: lex, fromParent: self)
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        let condFrame = XCTLConditionParentStatementFrame()
        context.recordConditionFrame(condFrame)
        self.holdingObject = try self.switchingObjectStmt.evaluate(inContext: context)
        if self.holdingObject.type == .typeVoid {
            throw XCTLRuntimeError.unexpectedVariableType(expect: "any", butGot: "void")
        }
        return try self.childrenStmt.evaluate(inContext: context)
    }
    
}
