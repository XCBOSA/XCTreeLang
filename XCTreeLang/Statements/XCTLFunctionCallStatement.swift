//
//  XCTLFunctionCallStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

internal class XCTLFunctionCallStatement: XCTLStatement, XCTLExpressionPart {
    
    var type: XCTLStatementType { .typeFunctionCall }
    
    var expressionValue: XCTLExpressionValue { .consume }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var argumentStatements = [XCTLStatement]()
    
    weak var parent: XCTLStatement?
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        if try lex.next().type == .typeOpenBracket {
            return XCTLFunctionCallStatement()
        }
        return nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        
        _ = try lex.next()
        
        while try lex.peek().type != .typeCloseBracket {
            self.argumentStatements.append(try self.parseNextExpression(forLexer: lex))
        }
        
        try lex.next()
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        if let funcValue = context.variableStack.popVariable() {
            let arg = try argumentStatements.map({ try $0.evaluate(inContext: context) })
            if funcValue.type == .typeFuncImpl,
               let funcStmt = funcValue.rawFunctionStatement as? XCTLLateExecuteStatement {
                let result = try funcStmt.doRealEvaluate(inContext: context, withArgs: arg)
                context.variableStack.pushVariable(result)
                return result
            }
            if funcValue.type != .typeFuncIntrinsic {
                throw XCTLRuntimeError.unexpectedVariableType(expect: XCTLRuntimeVariableType.typeFuncIntrinsic.rawValue, butGot: funcValue.type.rawValue)
            }
            let result = funcValue.executeFunc(arg: arg)
            context.variableStack.pushVariable(result)
            return result
        }
        throw XCTLRuntimeError.variableStackNoObject
    }
    
}
