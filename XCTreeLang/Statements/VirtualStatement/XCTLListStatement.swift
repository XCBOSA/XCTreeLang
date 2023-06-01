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
        let frame = XCTLListStatementFrame()
        context.recordListFrame(frame)
        let context = context.makeSubContext()
        var lastValue = XCTLRuntimeVariable.void
        for it in statements {
            let newValue = try it.evaluate(inContext: context)
            if newValue.type != .typeVoid {
                lastValue = newValue
            }
            if frame.breakListEvaluate {
                break
            }
        }
        return frame.listResultValue.type == .typeVoid ? lastValue : frame.listResultValue
    }
    
}
