//
//  XCTLStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

internal protocol XCTLStatement: AnyObject {
    
    var type: XCTLStatementType { get }
    
    /// 例如，switch语句正在判断的对象，可以为void
    var holdingObject: XCTLRuntimeVariable { get }
    
    var parent: XCTLStatement? { get }
    
    /// 判断Lex状态是否符合当前表达式
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement?
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable
    
//    func evaluateAfter(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable
    
}

internal protocol XCTLListStatementProtocol: AnyObject {
    
    var conditionParent: XCTLConditionParentStatement? { get }
    
    var paragraphHold: Bool { get set }
    
}

internal protocol XCTLConditionParentStatement: AnyObject {
    
}

internal protocol XCTLLateExecuteStatement: AnyObject {
    
    func doRealEvaluate(inContext context: XCTLRuntimeAbstractContext,
                        withArgs args: [XCTLRuntimeVariable]) throws -> XCTLRuntimeVariable
    
}

internal protocol XCTLBackableStatement: AnyObject {
    
    func evaluateBack(_ valueToBack: XCTLRuntimeVariable, inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable
    
}

internal class XCTLConditionParentStatementFrame {
    var doElse: Bool
    var doNext: Bool
    
    internal init() {
        self.doElse = true
        self.doNext = false
    }
    
    internal init(doElse: Bool, doNext: Bool) {
        self.doElse = doElse
        self.doNext = doNext
    }
}

internal class XCTLListStatementFrame {
    var breakListEvaluate: Bool
    var breakToParagraph: Bool
    var listResultValue: XCTLRuntimeVariable
    
    internal init() {
        self.breakListEvaluate = false
        self.breakToParagraph = true
        self.listResultValue = .void
    }
    
    internal init(breakListEvaluate: Bool, breakToParagraph: Bool, listResultValue: XCTLRuntimeVariable) {
        self.breakListEvaluate = breakListEvaluate
        self.breakToParagraph = breakToParagraph
        self.listResultValue = listResultValue
    }
}

internal class XCTLForStatementFrame {
    var breakForEvaluate: Bool
    
    internal init() {
        self.breakForEvaluate = false
    }
    
    internal init(breakForEvaluate: Bool) {
        self.breakForEvaluate = breakForEvaluate
    }
}

internal var XCTLStatementPrototypes: [XCTLStatement] = [
    XCTLImportStatement(),
    XCTLExportStatement(),
    XCTLInitStatement(),
    XCTLFunctionCallStatement(),
    XCTLLazyEqualStatement(),
    XCTLImmediateStatement(),
    XCTLVariableRefStatement(),
    XCTLSwitchStatement(),
    XCTLLessthanStatement(),
    XCTLMorethanStatement(),
    XCTLEqualthanStatement(),
    XCTLNextthanStatement(),
    XCTLElseStatement(),
    XCTLParagraphStatement(),
    XCTLSetStatement(),
    XCTLReturnStatement(),
    XCTLForStatement(),
    XCTLBreakStatement(),
    XCTLContinueStatement()
]

internal var XCTLExpressionPrototypes: [XCTLStatement] = [
    XCTLFunctionCallStatement(),
    XCTLImmediateStatement(),
    XCTLVariableRefStatement()
]

internal func XCTLStatementParseNextStatement(forLexer lex: XCTLLexer,
                                              fromParent parent: XCTLStatement?,
                                              prototypes: [XCTLStatement] = XCTLStatementPrototypes) throws -> XCTLStatement {
    for it in prototypes {
        let pos = lex.position
        let debug = lex.debugMode
        lex.debugMode = false
        let matchStatement = try it.matchSelfStatement(lex: lex)
        lex.position = pos
        lex.debugMode = debug
        if let newIt = matchStatement {
            if lex.debugMode {
                print("[AST] Bgn \(newIt.type)")
            }
            try newIt.parseStatement(fromLexerToSelf: lex, fromParent: parent)
            if lex.debugMode {
                print("[AST] End \(newIt.type)")
            }
            return newIt
        }
    }
    throw XCTLCompileTimeError.unknownStatementPrefix(string: try lex.next().rawValue)
}

internal extension XCTLStatement {
    
    func parseNextStatement(forLexer lex: XCTLLexer, prototypes: [XCTLStatement] = XCTLStatementPrototypes) throws -> XCTLStatement {
        return try XCTLStatementParseNextStatement(forLexer: lex, fromParent: self, prototypes: prototypes)
    }
    
    func parseNextExpression(forLexer lex: XCTLLexer, terminator: XCTLTokenType = .typeEOF) throws -> XCTLStatement & XCTLExpression {
        let prefixExpr = XCTLPrefixExpression()
        try prefixExpr.parseStatement(fromLexerToSelf: lex, fromParent: self, terminatorType: terminator)
        return prefixExpr
    }
    
}
