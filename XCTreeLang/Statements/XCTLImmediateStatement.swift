//
//  XCTLImmediateStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

internal class XCTLImmediateStatement: XCTLStatement {
    
    var type: XCTLStatementType { .typeImmediateValue }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var immediateToken: XCTLToken = .eof
    
    weak var parent: XCTLStatement?
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        return try (lex.peek().type == .typeImmediateString ||
            lex.peek().type == .typeImmediateNumber ||
                lex.peek().type == .typeImmediateBool) ? XCTLImmediateStatement() : nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        self.immediateToken = try lex.next()
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        switch immediateToken.type {
        case .typeImmediateString:
            return .init(type: .typeString, rawValue: immediateToken.rawValue)
        case .typeImmediateNumber:
            return .init(type: .typeNumber, rawValue: immediateToken.rawValue)
        case .typeImmediateBool:
            return .init(type: .typeBoolean, rawValue: immediateToken.rawValue)
        default:
            fatalError()
        }
    }
    
}
