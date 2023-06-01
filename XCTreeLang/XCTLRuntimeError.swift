//
//  XCTLRuntimeError.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation

public enum XCTLRuntimeError: Error {
    
    case importUnknownMember(variableName: String)
    case undefinedVariable(variableName: String)
    case unknownMemberForVariable(memberName: String, variableName: String)
    case unexpectedVariableType(expect: String, butGot: String)
    
    case generateProtocolArgumentError(needs: String)
    case generateProtocolNotFoundedError(name: String)
    
    case parentNoHoldingObject
    
    case paragraphArgsNotEnough(needCount: Int, butGot: Int)
    
    case invalidConditionFrame
    case invalidListFrame
    
    case variableNotImplementProtocol(protocolName: String)
    
}

