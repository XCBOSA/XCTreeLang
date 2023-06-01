//
//  XCTLLazyEqualStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

internal class XCTLLazyEqualStatement: XCTLStatement {
    
    var type: XCTLStatementType { .typeLazyEqual }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var thisMemberName: String = ""
    var equalToStatement: XCTLStatement = XCTLImmediateStatement()
    
    weak var parent: XCTLStatement?
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        if try lex.next().type == .typeXOR,
            try lex.next().type == .typeIdentifier,
            try lex.next().type == .typeEqual {
            return XCTLLazyEqualStatement()
        }
        return nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        try lex.next()
        let leftToken = try lex.next()
        if leftToken.type != .typeIdentifier {
            throw XCTLCompileTimeError.unexpectTokenInStatement(expect: XCTLTokenType.typeIdentifier.rawValue, butGot: leftToken.type.rawValue)
        }
        self.thisMemberName = leftToken.rawValue
        let equalToken = try lex.next()
        if equalToken.type != .typeEqual {
            throw XCTLCompileTimeError.unexpectTokenInStatement(expect: XCTLTokenType.typeEqual.rawValue, butGot: equalToken.type.rawValue)
        }
        self.equalToStatement = try self.parseNextStatement(forLexer: lex)
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        guard let parent = self.parent as? XCTLInitStatement,
              let operationObject = parent.generatedObject else {
            throw XCTLCompileTimeError.unexpectParentStatementType(expect: "value", butGot: "got lazy nothing")
        }
        let rightValue = try equalToStatement.evaluate(inContext: context)
        if operationObject.type != .typeObject {
            throw XCTLRuntimeError.unexpectedVariableType(expect: XCTLRuntimeVariableType.typeObject.rawValue, butGot: operationObject.type.rawValue)
        }
        operationObject.objectValue.setValue(rightValue.nativeValue, forKey: self.thisMemberName)
        return .void
    }
    
}

