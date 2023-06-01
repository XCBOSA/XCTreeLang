//
//  XCTLListStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/25.
//

import Foundation

internal class XCTLListStatement: XCTLStatement, XCTLListStatementProtocol {
    
    var holdingObject: XCTLRuntimeVariable {
        self.parent?.holdingObject ?? .void
    }
    
    var type: XCTLStatementType { .typeStatementList }
    
    var breakListEvaluate: Bool = false
    
    var listResultValue: XCTLRuntimeVariable = .void
    
    private var statements = [XCTLStatement]()
    
    internal weak var parent: XCTLStatement?
    
    var conditionParent: XCTLConditionParentStatement? {
        var stmt: XCTLStatement? = self.parent
        while true {
            if let condStmt = stmt as? XCTLConditionParentStatement {
                return condStmt
            }
            stmt = stmt?.parent
            if stmt == nil {
                return nil
            }
        }
    }
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        fatalError("Virtual Statement")
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        let openBraceToken = try lex.next()
        if openBraceToken.type != .typeOpenBrace {
            throw XCTLCompileTimeError.unexpectTokenInStatement(expect: "{", butGot: openBraceToken.rawValue)
        }
        while try lex.peek().type != .typeCloseBrace {
            self.statements.append(try self.parseNextStatement(forLexer: lex))
        }
        try lex.next()
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        var lastValue = XCTLRuntimeVariable.void
        for it in statements {
            lastValue = try it.evaluate(inContext: context)
            if self.breakListEvaluate {
                break
            }
        }
        return listResultValue.type == .typeVoid ? lastValue : listResultValue
    }
    
}
