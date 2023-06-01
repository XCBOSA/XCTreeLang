//
//  XCTLNextthanStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/25.
//

import Foundation

internal class XCTLNextthanStatement: XCTLStatement {
    
    var type: XCTLStatementType { .typeNextthan }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    weak var parent: XCTLStatement?
    weak var parentCond: XCTLConditionParentStatement?
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        if try lex.next().type == .typeNextthan {
            return XCTLNextthanStatement()
        }
        return nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        self.parentCond = (self.parent as? XCTLListStatementProtocol)?.conditionParent
        if self.parent == nil || self.parentCond == nil {
            throw XCTLCompileTimeError.unexpectParentStatementType(expect: "codeList & cond", butGot: "\(fromParent?.type.rawValue ?? "none")")
        }
        try lex.next()
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        guard let listFrame = context.findListFrame() else {
            throw XCTLRuntimeError.invalidListFrame
        }
        guard let condFrame = context.findConditionFrame() else {
            throw XCTLRuntimeError.invalidConditionFrame
        }
        listFrame.breakListEvaluate = true
        condFrame.doNext = true
        return .void
    }
    
}
