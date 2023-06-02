//
//  XCTLImportStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

internal class XCTLImportStatement: XCTLStatement {
    
    var type: XCTLStatementType { .typeImport }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var variableName: String = ""
    
    weak var parent: XCTLStatement?
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        return try lex.peek().type == .typeImport ? XCTLImportStatement() : nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        try lex.next()
        let variableNameToken = try lex.next()
        if variableNameToken.type != .typeIdentifier {
            throw XCTLCompileTimeError.unexpectTokenInStatement(expect: XCTLTokenType.typeIdentifier.rawValue, butGot: variableNameToken.type.rawValue)
        }
        self.variableName = variableNameToken.rawValue
        
        lex.lastStatement = self
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        context.addImport(name: self.variableName)
        return .void
    }
    
}
