//
//  XCTLInitStatement.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

internal class XCTLInitStatement: XCTLStatement {
    
    var type: XCTLStatementType { .typeInit }
    
    var holdingObject: XCTLRuntimeVariable = .void
    
    var typeName: String = ""
    var defineName: String = ""
    var initArgumentStatements = [XCTLStatement]()
    var lazyInitStatements = [XCTLStatement]()
    
    var generatedObject: XCTLRuntimeVariable?
    
    weak var parent: XCTLStatement?
    
    func matchSelfStatement(lex: XCTLLexer) throws -> XCTLStatement? {
        let pos = lex.position
        if try lex.next().type == .typeIdentifier,
           try lex.next().type == .typeIdentifier,
           try lex.next().type == .typeOpenBrace {
            return XCTLInitStatement()
        }
        lex.position = pos
        if try lex.next().type == .typeIdentifier,
           try lex.next().type == .typeOpenBrace {
            return XCTLInitStatement()
        }
        return nil
    }
    
    func parseStatement(fromLexerToSelf lex: XCTLLexer, fromParent: XCTLStatement?) throws {
        self.parent = fromParent
        let typeName = try lex.next()
        self.typeName = typeName.rawValue
        let nextType = try lex.peek().type
        var continueDefine = false
        switch nextType {
        case .typeIdentifier:
            continueDefine = true
            break
        case .typeOpenBrace:
            continueDefine = false
            break
        default:
            throw XCTLCompileTimeError.unexpectTokenInStatement(expect: "typeIdentifier or typeOpenBrace", butGot: nextType.rawValue)
        }
        if continueDefine {
            let nameToken = try lex.next()
            defineName = nameToken.rawValue
        } else {
            defineName = "unnamedObject_" + UUID().uuidString
        }
        let openBrace1 = try lex.next()
        if openBrace1.type != .typeOpenBrace {
            throw XCTLCompileTimeError.unexpectTokenInStatement(expect: XCTLTokenType.typeOpenBrace.rawValue, butGot: openBrace1.type.rawValue)
        }
        while let closeBrace = try? lex.peek(),
           closeBrace.type != .typeCloseBrace {
            let innerStatement = try self.parseNextStatement(forLexer: lex)
            self.initArgumentStatements.append(innerStatement)
        }
        try lex.next()
        if try lex.peek().type == .typeOpenBrace {
            try lex.next()
            while let closeBrace = try? lex.peek(),
               closeBrace.type != .typeCloseBrace {
                let innerStatement = try self.parseNextStatement(forLexer: lex)
                self.lazyInitStatements.append(innerStatement)
            }
            try lex.next()
        }
    }
    
    func evaluate(inContext context: XCTLRuntimeAbstractContext) throws -> XCTLRuntimeVariable {
        var variables = [XCTLRuntimeVariable]()
        for statement in initArgumentStatements {
            let value = try statement.evaluate(inContext: context)
            if value.type != .typeVoid {
                variables.append(value)
            }
        }
        let object = try context.allocateObject(name: typeName, args: variables)
        self.generatedObject = object
        context.setValue(object, forName: self.defineName)
        self.holdingObject = object
        for it in self.lazyInitStatements {
            context.addLazyStatement(it)
        }
        return object
    }
    
}
