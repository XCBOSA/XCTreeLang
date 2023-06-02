//
//  XCTLPrefixExpression.swift
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/2.
//

import Foundation

internal class XCTLPrefixExpression: XCTLStatement, XCTLExpression {
    
    var type: XCTLStatementType { .expressionPrefix }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var parent: XCTLStatement?
    
    var statements = [XCTLStatement]()
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        fatalError("\(self.type.rawValue) can not parse automatically.")
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        fatalError("\(self.type.rawValue) can not parse automatically.")
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?, terminatorType: XCTLTokenType) throws {
        self.parent = fromParent
        var stackValue = 0
        while try lex.peek().type != terminatorType {
            var stmt: XCTLStatement & XCTLExpressionPart
            let position = lex.position
            
            do {
                stmt = try self.parseNextStatement(forLexer: lex, prototypes: XCTLExpressionPrototypes) as! XCTLStatement & XCTLExpressionPart
            } catch _ as XCTLCompileTimeError {
                lex.position = position
                break
            }
            
            stackValue += stmt.expressionValue.rawValue
            if stackValue > 1 {
                lex.position = position
                break
            }
            
            self.statements.append(stmt)
            
            if stmt.type == .typeFunctionCall {
                break
            }
        }
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        let originalVariableStack = context.variableStack
        
        let variableStack = XCTLRuntimeVariableStackFrame()
        context.variableStack = variableStack
        for it in statements {
            _ = try it.evaluate(inContext: context)
        }
        guard let resultValue = variableStack.popVariable() else {
            throw XCTLRuntimeError.variableStackNoObject
        }
        if !variableStack.isEmpty {
            throw XCTLRuntimeError.variableStackNotEmptyAfterTerminator
        }
        
        context.variableStack = originalVariableStack
        return resultValue
    }
    
}
