//
//  XCTLRootStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

internal class XCTLRootStatement: XCTLStatement {
    
    var type: XCTLStatementType { .typeRootStatement }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var statements = [XCTLStatement]()
    
    var parent: XCTLStatement? { nil }
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        return lex.position == 0 ? XCTLRootStatement() : nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        while try lex.peek().type != .typeEOF {
            let statement = try self.parseNextStatement(forLexer: lex)
            self.statements.append(statement)
        }
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        for it in statements {
            _ = try it.evaluate(inContext: context)
        }
        return .void
    }
    
}
