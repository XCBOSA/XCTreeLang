//
//  XCTLRuntimeType.swift
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/1.
//

import Foundation
import XCTLRuntimeTypeInstanceModule

@objcMembers
public class XCTLRuntimeFunctionDef: NSObject {
    public var selector: String
    public var argumentCount: Int
    
    public init(selector: String, argumentCount: Int) {
        self.selector = selector
        self.argumentCount = argumentCount
    }
}

@objcMembers
public class XCTLRuntimeType: NSObject {
    
    private var variableNameWithTypeTable = [String : String]()
    private var paragraphTable = [String : XCTLParagraphStatement]()
    private let klassName: String
    
    internal init(variableNameWithTypeTable: [String : String] = [String : String](), paragraphTable: [String : XCTLParagraphStatement] = [String : XCTLParagraphStatement](), className: String) {
        self.variableNameWithTypeTable = variableNameWithTypeTable
        self.paragraphTable = paragraphTable
        self.klassName = className
    }
    
    public func addVariable(name: String, type: String) throws {
        if self.variableNameWithTypeTable.keys.contains(type) {
            throw XCTLCompileTimeError.duplicatedMemberVariable(name: type)
        }
        self.variableNameWithTypeTable[name] = type
    }
    
    internal func addParagraph(name: String, paragraph: XCTLParagraphStatement) throws {
        if self.paragraphTable.keys.contains(name) {
            throw XCTLCompileTimeError.duplicatedMemberParagraph(name: name)
        }
        self.paragraphTable[name] = paragraph
    }
    
    internal func invokeParagraph(_ name: String,
                                  forInstance instance: XCTLRuntimeTypeInstance,
                                  inContext context: XCTLRuntimeAbstractContext,
                                  withArgs args: [XCTLRuntimeVariable]) throws -> XCTLRuntimeVariable {
        guard let paragraph = self.paragraphTable[name] else {
            throw XCTLRuntimeError.unknownMethodForName(name: name)
        }
        var args = args
        args.insert(XCTLRuntimeVariable(rawObject: instance), at: 0)
        return try paragraph.doRealEvaluate(inContext: context, withArgs: args)
    }
    
    public func makeRuntimeFuncDef() -> [XCTLRuntimeFunctionDef] {
        var defs = [XCTLRuntimeFunctionDef]()
        for it in self.paragraphTable {
            defs.append(XCTLRuntimeFunctionDef(selector: it.key, argumentCount: it.value.argumentIdList.count))
        }
        return defs
    }
    
    public func makeVariableTable() -> [String : String] {
        return self.variableNameWithTypeTable
    }
    
    public func runtimeClassName() -> String {
        return self.klassName
    }
    
    public func invokeParagraph(_ name: String, forInstance: XCTLRuntimeTypeInstance, inContext: Any, withArgs args: [NSObject]) {
        
    }
    
}
