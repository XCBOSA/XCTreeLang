//
//  XCTLImmediateStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

internal class XCTLImmediateStatement: XCTLStatement, XCTLExpressionPart {
    
    var type: XCTLStatementType { .typeImmediateValue }
    
    var expressionValue: XCTLExpressionValue { .product }
    
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
        
        lex.lastStatement = self
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        var resultValue: XCTLRuntimeVariable
        switch immediateToken.type {
        case .typeImmediateString:
            resultValue = .init(type: .typeString, rawValue: immediateToken.rawValue)
        case .typeImmediateNumber:
            resultValue = .init(type: .typeNumber, rawValue: immediateToken.rawValue)
        case .typeImmediateBool:
            resultValue = .init(type: .typeBoolean, rawValue: immediateToken.rawValue)
        default:
            fatalError()
        }
        context.variableStack.pushVariable(resultValue)
        return resultValue
    }
    
}
