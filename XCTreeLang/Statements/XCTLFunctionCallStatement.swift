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
    
    var selectorAppendix = ""
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        if try lex.next().type == .typeOpenBracket {
            return XCTLFunctionCallStatement()
        }
        return nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        
        guard let variable = lex.lastStatement as? XCTLVariableRefStatement else {
            throw XCTLCompileTimeError.invalidObjectForFuncCall
        }
        
        _ = try lex.next()
        
        var firstArg = true
        while try lex.peek().type != .typeCloseBracket {
            let pos = lex.position
            if (try? lex.next().type) == .typeIdentifier,
               (try? lex.next().type) == .typeColon {
                lex.position = pos
                var flag = try lex.next().rawValue
                try lex.next()
                if firstArg {
                    selectorAppendix.append("With")
                    flag = flag.removeFirst().uppercased() + flag
                    selectorAppendix.append(flag)
                } else {
                    selectorAppendix.append(flag)
                }
            } else {
                lex.position = pos
                if !firstArg {
                    selectorAppendix.append("_")
                }
            }
            selectorAppendix.append(":")
            self.argumentStatements.append(try self.parseNextExpression(forLexer: lex))
            firstArg = false
        }
        
        var childVariable = variable
        while let c = childVariable.nextVariableRefStmt {
            childVariable = c
        }
        childVariable.variableName.append(selectorAppendix)
        
        try lex.next()
        
        lex.lastStatement = self
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
            let result = try funcValue.executeFunc(arg: arg)
            context.variableStack.pushVariable(result)
            return result
        }
        throw XCTLRuntimeError.variableStackNoObject
    }
    
}
