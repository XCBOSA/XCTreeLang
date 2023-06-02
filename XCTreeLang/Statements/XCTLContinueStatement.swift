//
//  XCTLContinueStatement.swift
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/1.
//

import Foundation

internal class XCTLContinueStatement: XCTLStatement {
    
    var type: XCTLStatementType { .typeContinue }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var parent: XCTLStatement?
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        if try lex.next().type == .typeContinue {
            return XCTLContinueStatement()
        }
        return nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        var parentStmt = self.parent
        var founded = false
        while let stmt = parentStmt {
            if stmt is XCTLForStatement {
                founded = true
            }
            if stmt is XCTLParagraphStatement {
                break
            }
            parentStmt = stmt.parent
        }
        if !founded {
            throw XCTLCompileTimeError.unexpectParentStatementType(expect: "for", butGot: "...")
        }
        try _ = lex.next()
        
        lex.lastStatement = self
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        if let listFrame = context.findListFrame() {
            listFrame.breakListEvaluate = true
            listFrame.breakToParagraph = false
        }
        return .void
    }
    
}
