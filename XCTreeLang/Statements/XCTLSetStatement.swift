//
//  XCTLSetStatement.swift
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/1.
//

import Foundation

internal class XCTLSetStatement: XCTLStatement {
    
    var type: XCTLStatementType { .typeSet }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var variableName: String = ""
    
    var setToStatement: XCTLStatement!
    
    weak var parent: XCTLStatement?
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        return try lex.peek().type == .typeSet ? XCTLSetStatement() : nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        try lex.next()
        
        let variableNameToken = try lex.next()
        if variableNameToken.type != .typeIdentifier {
            throw XCTLCompileTimeError.unexpectTokenInStatement(expect: XCTLTokenType.typeIdentifier.rawValue, butGot: variableNameToken.type.rawValue)
        }
        self.variableName = variableNameToken.rawValue
        
        let equalToken = try lex.next()
        if equalToken.type != .typeEqual {
            throw XCTLCompileTimeError.unexpectTokenInStatement(expect: XCTLTokenType.typeEqual.rawValue, butGot: equalToken.type.rawValue)
        }
        
        self.setToStatement = try self.parseNextStatement(forLexer: lex, prototypes: XCTLExpressionPrototypes)
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        let value = try self.setToStatement.evaluate(inContext: context)
        context.setValue(value, forName: self.variableName)
        return value
    }
    
}
