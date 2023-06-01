//
//  XCTLFunctionCallStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

internal class XCTLFunctionCallStatement: XCTLStatement {
    
    var type: XCTLStatementType { .typeFunctionCall }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var functionName: String = ""
    var argumentStatements = [XCTLStatement]()
    
    weak var parent: XCTLStatement?
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        if try lex.next().type == .typeIdentifier,
           try lex.next().type == .typeOpenBracket {
            return XCTLFunctionCallStatement()
        }
        return nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
//        try lex.next()
        let identifier = try lex.next()
        if identifier.type != .typeIdentifier {
            throw XCTLCompileTimeError.unexpectTokenInStatement(expect: XCTLTokenType.typeIdentifier.rawValue, butGot: identifier.type.rawValue)
        }
        self.functionName = identifier.rawValue
        let openBracket = try lex.next()
        if openBracket.type != .typeOpenBracket {
            throw XCTLCompileTimeError.unexpectTokenInStatement(expect: XCTLTokenType.typeOpenBracket.rawValue, butGot: identifier.type.rawValue)
        }
        while try lex.peek().type != .typeCloseBracket {
            self.argumentStatements.append(try self.parseNextStatement(forLexer: lex))
        }
        try lex.next()
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        if let funcValue = context.value(forName: self.functionName) {
            let arg = try argumentStatements.map({ try $0.evaluate(inContext: context) })
            if funcValue.type == .typeFuncImpl,
               let funcStmt = funcValue.rawFunctionStatement as? XCTLLateExecuteStatement {
                return try funcStmt.doRealEvaluate(inContext: context, withArgs: arg)
            }
            if funcValue.type != .typeFuncIntrinsic {
                throw XCTLRuntimeError.unexpectedVariableType(expect: XCTLRuntimeVariableType.typeFuncIntrinsic.rawValue, butGot: funcValue.type.rawValue)
            }
            return funcValue.executeFunc(arg: arg)
        }
        throw XCTLRuntimeError.undefinedVariable(variableName: self.functionName)
    }
    
}
