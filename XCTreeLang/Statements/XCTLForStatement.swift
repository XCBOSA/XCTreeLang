//
//  XCTLForStatement.swift
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/1.
//

import Foundation

public class XCTLForStatement: XCTLStatement {
    
    var type: XCTLStatementType { .typeFor }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var parent: XCTLStatement?
    
    var iteratorName: String = ""
    
    var enumeratorVariableStatement: XCTLStatement!
    
    var listStatement = XCTLListStatement()
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        if try lex.next().type == .typeFor {
            return XCTLForStatement()
        }
        return nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        try lex.next()
        
        let iteratorNameToken = try lex.next()
        if iteratorNameToken.type != .typeIdentifier {
            throw XCTLCompileTimeError.unexpectTokenInStatement(expect: XCTLTokenType.typeIdentifier.rawValue, butGot: iteratorNameToken.rawValue)
        }
        self.iteratorName = iteratorNameToken.rawValue
        
        let inToken = try lex.next()
        if inToken.type != .typeIn {
            throw XCTLCompileTimeError.unexpectTokenInStatement(expect: XCTLTokenType.typeIn.rawValue, butGot: inToken.rawValue)
        }
        
        self.enumeratorVariableStatement = try self.parseNextExpression(forLexer: lex, terminator: .typeOpenBrace)
        
        try self.listStatement.parseStatement(fromLexerToSelf: lex, fromParent: self)
        
        lex.lastStatement = self
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        let enumeratorVariable = try self.enumeratorVariableStatement.evaluate(inContext: context)
        if enumeratorVariable.type != .typeObject {
            throw XCTLRuntimeError.unexpectedVariableType(expect: XCTLRuntimeVariableType.typeObject.rawValue, butGot: enumeratorVariable.type.rawValue)
        }
        
        var enumerator: XCTLEnumerator!
        if let enumeratorImpl = enumeratorVariable.objectValue as? XCTLEnumerator {
            enumerator = enumeratorImpl
        }
        if let enumeratorProvider = enumeratorVariable.objectValue as? XCTLEnumeratorProvider {
            enumerator = enumeratorProvider.provideEnumerator()
        }
        if enumerator == nil {
            throw XCTLRuntimeError.variableNotImplementProtocol(protocolName: "XCTLEnumerator or XCTLEnumeratorProvider")
        }
        
        let context = context.makeSubContext()
        let listFrame = context.findListFrame()
        let forFrame = XCTLForStatementFrame()
        context.recordForFrame(forFrame)
        while true {
            let value = enumerator.moveNext()
            if value.type == .typeVoid {
                break
            }
            context.setValueIgnoreParent(value, forName: self.iteratorName)
            _ = try self.listStatement.evaluate(inContext: context)
            if forFrame.breakForEvaluate {
                break
            }
            if let listFrame = listFrame,
               listFrame.breakListEvaluate {
                break
            }
        }
        
        return .void
    }
    
}
