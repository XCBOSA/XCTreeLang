//
//  XCTLLexer.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

internal class XCTLLexer {
    
    internal var position: Int = 0
    
    internal let document: [Character]
    
    internal var debugMode = true
    
    internal var paragraphTable = [String : XCTLStatement]()
    
    internal weak var lastStatement: XCTLStatement?
    
    init(document: String) {
        self.document = [Character](document)
    }
    
    internal func peek() throws -> XCTLToken {
        let position = self.position
        let value = try self._next()
        self.position = position
        return value
    }
    
    @discardableResult
    internal func next() throws -> XCTLToken {
        let token = try self._next()
        if self.debugMode {
            print("[LEX] \(token.rawValue): \(token.type.rawValue)")
        }
        return token
    }
    
    private func _next() throws -> XCTLToken {
        guard let char = peekChar() else {
            return .eof
        }
        position += 1
        if char.isLetter || char == "_" {
            var buffer = "\(char)"
            while true {
                guard let nextChar = peekChar(),
                      !nextChar.isWhitespace,
                      (nextChar.isLetter || nextChar.isNumber || nextChar == "_") else {
                    break
                }
                position += 1
                buffer.append(nextChar)
            }
            switch buffer {
            case "import":
                return XCTLToken(type: .typeImport, rawValue: buffer)
            case "export":
                return XCTLToken(type: .typeExport, rawValue: buffer)
            case "true":
                return XCTLToken(type: .typeImmediateBool, rawValue: buffer)
            case "false":
                return XCTLToken(type: .typeImmediateBool, rawValue: buffer)
            case "switch":
                return XCTLToken(type: .typeSwitch, rawValue: buffer)
            case "lessthan":
                return XCTLToken(type: .typeLessthan, rawValue: buffer)
            case "morethan":
                return XCTLToken(type: .typeMorethan, rawValue: buffer)
            case "nextthan":
                return XCTLToken(type: .typeNextthan, rawValue: buffer)
            case "equalthan":
                return XCTLToken(type: .typeEqualthan, rawValue: buffer)
            case "paragraph":
                return XCTLToken(type: .typeParagraph, rawValue: buffer)
            case "function":
                return XCTLToken(type: .typeParagraph, rawValue: buffer)
            case "func":
                return XCTLToken(type: .typeParagraph, rawValue: buffer)
            case "set":
                return XCTLToken(type: .typeSet, rawValue: buffer)
            case "else":
                return XCTLToken(type: .typeElse, rawValue: buffer)
            case "return":
                return XCTLToken(type: .typeReturn, rawValue: buffer)
            case "for":
                return XCTLToken(type: .typeFor, rawValue: buffer)
            case "in":
                return XCTLToken(type: .typeIn, rawValue: buffer)
            case "break":
                return XCTLToken(type: .typeBreak, rawValue: buffer)
            case "continue":
                return XCTLToken(type: .typeContinue, rawValue: buffer)
            case "class":
                return XCTLToken(type: .typeClass, rawValue: buffer)
            default:
                return XCTLToken(type: .typeIdentifier, rawValue: buffer)
            }
        }
        if char.isNumber {
            var buffer = "\(char)"
            while true {
                guard let nextChar = peekChar(),
                      "1234567890.".contains(nextChar) else {
                    break
                }
                position += 1
                buffer.append(nextChar)
            }
            if Double(buffer) == nil {
                throw XCTLCompileTimeError.notValidNumber(string: buffer)
            }
            return XCTLToken(type: .typeImmediateNumber, rawValue: buffer)
        }
        if char == "\"" {
            var buffer = ""
            var ignoreNext = false
            while true {
                guard let nextChar = peekChar() else {
                    throw XCTLCompileTimeError.stringNotTerminate(string: "\"\(buffer)")
                }
                position += 1
                if ignoreNext {
                    ignoreNext = false
                } else {
                    if nextChar == "\\" {
                        ignoreNext = true
                    }
                    if nextChar == "\"" {
                        break
                    }
                }
                buffer.append(nextChar)
            }
            return XCTLToken(type: .typeImmediateString, rawValue: buffer)
        }
        if char.isWhitespace {
            return try self._next()
        }
        switch char {
        case "{":
            return XCTLToken(type: .typeOpenBrace, rawValue: "\(char)")
        case "}":
            return XCTLToken(type: .typeCloseBrace, rawValue: "\(char)")
        case "(":
            return XCTLToken(type: .typeOpenBracket, rawValue: "\(char)")
        case ")":
            return XCTLToken(type: .typeCloseBracket, rawValue: "\(char)")
        case "=":
            return XCTLToken(type: .typeEqual, rawValue: "\(char)")
        case "@":
            return XCTLToken(type: .typeAt, rawValue: "\(char)")
        case "^":
            return XCTLToken(type: .typeXOR, rawValue: "\(char)")
        case "$":
            return XCTLToken(type: .typeValue, rawValue: "\(char)")
        case ".":
            return XCTLToken(type: .typePoint, rawValue: "\(char)")
        case ":":
            return XCTLToken(type: .typeColon, rawValue: "\(char)")
        default:
            throw XCTLCompileTimeError.illegalCharacter(char: char)
        }
    }
    
    private func peekChar() -> Character? {
        if position >= 0 && position < document.count {
            return document[position]
        }
        return nil
    }
    
}
