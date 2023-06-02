//
//  XCTLError.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

public enum XCTLCompileTimeError: Error {
    
    case illegalCharacter(char: Character)
    case notValidNumber(string: String)
    case stringNotTerminate(string: String)
    case unknownStatementPrefix(string: String)
    case unexpectTokenInStatement(expect: String, butGot: String)
    case unexpectParentStatementType(expect: String, butGot: String)
    case tooMuchParagraphDefinitionForName(name: String)
    
    case duplicatedMemberVariable(name: String)
    case duplicatedMemberParagraph(name: String)
    
}
