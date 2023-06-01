//
//  XCTLVariableRefStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

internal class XCTLVariableRefStatement: XCTLStatement {
    
    var type: XCTLStatementType { .typeVariableRef }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var variableName: String = ""
    
    weak var parent: XCTLStatement?
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        if try lex.next().type == .typeIdentifier {
            return XCTLVariableRefStatement()
        }
        return nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
//        try lex.next()
        let value = try lex.next()
        self.variableName = value.rawValue
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        if let value = context.value(forName: variableName) {
            return value
        }
        throw XCTLRuntimeError.undefinedVariable(variableName: variableName)
    }
    
}
