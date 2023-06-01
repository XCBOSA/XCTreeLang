//
//  XCTLElseStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/25.
//

import Foundation

internal class XCTLElseStatement: XCTLStatement {
    
    var type: XCTLStatementType { .typeElse }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    private var listStmts = XCTLListStatement()
    
    weak var parent: XCTLStatement?
    weak var condStmt: XCTLConditionParentStatement?
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        if try lex.next().type == .typeElse {
            return XCTLElseStatement()
        }
        return nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        try lex.next()
        guard let parent = fromParent as? XCTLListStatementProtocol,
              let condStmt = parent.conditionParent else {
            throw XCTLCompileTimeError.unexpectParentStatementType(expect: "listStatements", butGot: "\(fromParent?.type.rawValue ?? "none")")
        }
        self.condStmt = condStmt
        try listStmts.parseStatement(fromLexerToSelf: lex, fromParent: self)
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        if self.condStmt?.doElse ?? false {
            return try self.listStmts.evaluate(inContext: context)
        }
        return .void
    }
    
}
