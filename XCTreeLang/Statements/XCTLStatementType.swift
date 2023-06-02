//
//  XCTLStatementType.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

internal enum XCTLStatementType: String {
    
    /// import Variable
    case typeImport
    /// export Variable
    case typeExport
    /// TypeName VariableName { Statements } [{ LazyEqual }]
    case typeInit
    /// @FunctionName(Argument)
    case typeFunctionCall
    /// Variable1 = Variable2
    case typeLazyEqual
    /// "abc" or 123 or false or true
    case typeImmediateValue
    /// $abc
    case typeVariableRef
    
    case typeRootStatement
    
    case typeSwitch
    
    case typeStatementList
    
    case typeLessthan
    case typeMorethan
    case typeEqualthan
    case typeElse
    case typeNextthan
    
    case typeParagraph
    
    case typeSet
    case typeReturn
    
    case typeFor
    case typeBreak
    case typeContinue
    
    case expressionPrefix
    
}
