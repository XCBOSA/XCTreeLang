//
//  XCTLReturnStatement.swift
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/1.
//

import Foundation

internal class XCTLReturnStatement: XCTLStatement {
    
    var type: XCTLStatementType { .typeReturn }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var returnValueStatement: XCTLStatement!
    
    weak var parent: XCTLStatement?
    
    weak var parentParagraph: XCTLParagraphStatement!
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        return try lex.peek().type == .typeReturn ? XCTLReturnStatement() : nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        
        var parentStmt: XCTLStatement? = self.parent
        while let stmt = parentStmt {
            if let listStmt = stmt as? XCTLParagraphStatement {
                self.parentParagraph = listStmt
                break
            }
            parentStmt = stmt.parent
        }
        
        if parentParagraph == nil {
            throw XCTLCompileTimeError.unexpectParentStatementType(expect: XCTLStatementType.typeParagraph.rawValue, butGot: self.parent?.type.rawValue ?? "none")
        }
        
        try lex.next()
        
        self.returnValueStatement = try self.parseNextExpression(forLexer: lex)
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        guard let listFrame = context.findListFrame() else {
            throw XCTLRuntimeError.invalidListFrame
        }
        let condFrame = context.findConditionFrame()
        let value = try self.returnValueStatement.evaluate(inContext: context)
        listFrame.breakListEvaluate = true
        listFrame.listResultValue = value
        condFrame?.doElse = false
        return value
    }
    
}

