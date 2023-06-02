//
//  XCTLTokenType.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

internal enum XCTLTokenType: String {
    
    case typeImport
    case typeExport
    case typeIdentifier
    case typeImmediateString
    case typeImmediateNumber
    case typeImmediateBool
    
    case typeSwitch
    case typeLessthan
    case typeEqualthan
    case typeElse
    case typeNextthan
    case typeParagraph
    case typeMorethan
    case typeSet
    
    /// {
    case typeOpenBrace
    /// }
    case typeCloseBrace
    /// (
    case typeOpenBracket
    /// )
    case typeCloseBracket
    /// =
    case typeEqual
    /// @
    case typeAt
    /// ^
    case typeXOR
    /// $
    case typeValue
    
    case typeEOF
    
    /// .
    case typePoint
    
    /// return
    case typeReturn
    
    case typeFor
    case typeIn
    case typeBreak
    case typeContinue
    case typeClass
    
}
