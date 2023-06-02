//
//  XCTLExpression.swift
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/2.
//

import Foundation

/// 表示语句的部分是向表达式栈推入值、消耗值还是不操作栈
internal enum XCTLExpressionValue: Int {
    /// 消耗值
    case consume = -1
    /// 推入值
    case product = 1
    /// 不操作表达式栈
    case none = 0
}

internal protocol XCTLExpression {
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?, terminatorType: XCTLTokenType) throws
    
}

internal protocol XCTLExpressionPart {
    
    var expressionValue: XCTLExpressionValue { get }
    
}
