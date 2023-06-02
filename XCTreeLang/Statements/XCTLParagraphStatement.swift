//
//  XCTLParagraph.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/25.
//

import Foundation

internal class XCTLParagraphStatement: XCTLStatement, XCTLLateExecuteStatement {
    
    var type: XCTLStatementType { .typeParagraph }
    
    var holdingObject: XCTLRuntimeVariable { .void }
    
    var paragraphName = ""
    var argumentIdList = [String]()
    
    var runStatements = XCTLListStatement()
    weak var parent: XCTLStatement?
    
    var selectorAppendix = ""
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        if try lex.next().type == .typeParagraph {
            return XCTLParagraphStatement()
        }
        return nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        try lex.next()
        let nameToken = try lex.next()
        guard nameToken.type == .typeIdentifier else {
            throw XCTLCompileTimeError.unexpectTokenInStatement(expect: XCTLTokenType.typeIdentifier.rawValue, butGot: nameToken.rawValue)
        }
        self.paragraphName = nameToken.rawValue
        if try lex.peek().type == .typeOpenBracket {
            try lex.next()
            
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
                    }
                    selectorAppendix.append(flag)
                } else {
                    lex.position = pos
                    if !firstArg {
                        selectorAppendix.append("_")
                    }
                }
                selectorAppendix.append(":")
                
                let idToken = try lex.next()
                if idToken.type != .typeIdentifier {
                    throw XCTLCompileTimeError.unexpectTokenInStatement(expect: XCTLTokenType.typeIdentifier.rawValue, butGot: idToken.rawValue)
                }
                self.argumentIdList.append(idToken.rawValue)
                
                firstArg = false
            }
            try lex.next()
        }
        self.paragraphName.append(self.selectorAppendix)
        
        self.runStatements.parent = self
        self.runStatements.paragraphHold = true
        try self.runStatements.parseStatement(fromLexerToSelf: lex, fromParent: self)
        if lex.paragraphTable[self.paragraphName] != nil {
            throw XCTLCompileTimeError.tooMuchParagraphDefinitionForName(name: self.paragraphName)
        }
        lex.paragraphTable[self.paragraphName] = self
        
        lex.lastStatement = self
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        return .void
    }
    
    func doRealEvaluate(inContext context: XCTLRuntimeAbstractContext,
                        withArgs args: [XCTLRuntimeVariable]) throws -> XCTLRuntimeVariable {
        let subContext = context.makeSubContext()
        var argId = 0
        for argumentId in self.argumentIdList {
            if argId >= args.count {
                throw XCTLRuntimeError.paragraphArgsNotEnough(needCount: self.argumentIdList.count, butGot: args.count)
            }
            subContext.setValueIgnoreParent(args[argId], forName: argumentId)
            argId += 1
        }
        return try self.runStatements.evaluate(inContext: subContext)
    }
    
}
