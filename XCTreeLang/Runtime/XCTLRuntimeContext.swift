//
//  XCTLRuntimeContext.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation
import UIKit

internal class XCTLRuntimeContext: XCTLRuntimeAbstractContext {
    
    public let nativeObjectInstance: NSObject
    
    private let generators: [String : XCTLGenerateProtocol.Type]
    
    private var values = [String : XCTLRuntimeVariable]()
    
    internal private(set) var lazyRunStatements = [XCTLStatement]()
    
    internal let stdout = XCTLStream(onAppendBlock: {
        print($0, terminator: "")
    })
    
    internal init(nativeObjectInstance: NSObject,
                  paragraphMembers: [String : XCTLStatement],
                  generators: [String : XCTLGenerateProtocol.Type]) {
        self.nativeObjectInstance = nativeObjectInstance
        self.generators = generators
        self.setValue(XCTLRuntimeVariable(funcImpl: {
            if $0.count == 1,
               let val = $0.first {
                if val.type != .typeString {
                    return .void
                }
                if let nativeImage = UIImage(named: val.stringValue) ?? UIImage(systemName: val.stringValue) {
                    return XCTLRuntimeVariable(rawObject: nativeImage)
                }
            }
            return .void
        }), forName: "image")
        self.setValue(XCTLRuntimeVariable(funcImpl: {
            if $0.count == 1,
               let val = $0.first {
                if val.type == .typeString {
                    return XCTLRuntimeVariable(type: .typeString, rawValue: NSLocalizedString(val.stringValue, comment: ""))
                }
            }
            return .void
        }), forName: "string")
        self.setValue(XCTLRuntimeVariable(funcImpl: {
            fatalError($0.first?.stringValue ?? "fatalError from XCT")
        }), forName: "appFatalError")
        self.setValue(XCTLRuntimeVariable(funcImpl: {
            for it in $0 {
                self.stdout.append(text: it.toString())
            }
            return .void
        }), forName: "log")
        self.setValue(XCTLRuntimeVariable(funcImpl: {
            for it in $0 {
                self.stdout.append(text: it.toString())
            }
            self.stdout.append(text: "\n")
            return .void
        }), forName: "logn")
        self.setValue(XCTLRuntimeVariable(type: .typeNumber, rawValue: "\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-1")"), forName: "appBundleVersion")
        for it in paragraphMembers {
            self.setValue(XCTLRuntimeVariable(funcImplStmt: it.value), forName: it.key)
        }
    }
    
    private var importNames = Set<String>()
    private var exportNames = Set<String>()
    
    internal func valueDefined(_ name: String) -> Bool {
        if self.importNames.contains(name) {
            return true
        }
        if self.values[name] != nil {
            return true
        }
        return false
    }
    
    internal func value(forName name: String) -> XCTLRuntimeVariable? {
        if name == "self" {
            return XCTLRuntimeVariable(rawObject: self.nativeObjectInstance)
        }
        if let value = self.values[name] {
            return value
        }
        if importNames.contains(name),
           let valueFromNative = self.nativeObjectInstance.value(forKey: name) as? NSObject {
            let object = XCTLRuntimeVariable(rawObject: valueFromNative)
            self.values[name] = object
            return object
        }
        return .void
    }
    
    internal func setValue(_ value: XCTLRuntimeVariable, forName name: String) {
        self.values[name] = value
        if exportNames.contains(name) {
            self.nativeObjectInstance.setValue(value.nativeValue, forKey: name)
        }
    }
    
    internal func setValueToRoot(_ value: XCTLRuntimeVariable, forName name: String) {
        self.values[name] = value
        self.nativeObjectInstance.setValue(value.nativeValue, forKey: name)
    }
    
    internal func addImport(name: String) {
        self.importNames.insert(name)
    }
    
    internal func addExport(name: String) {
        self.exportNames.insert(name)
    }
    
    internal func allocateObject(name: String, args: [XCTLRuntimeVariable]) throws -> XCTLRuntimeVariable {
        guard let generator = self.generators[name] else {
            throw XCTLRuntimeError.generateProtocolNotFoundedError(name: name)
        }
        let nativeObject = try generator.initWithXCT(args.compactMap({ $0.nativeValue }))
        let object = XCTLRuntimeVariable(rawObject: nativeObject)
        return object
    }
    
    internal func addLazyStatement(_ stmt: XCTLStatement) {
        self.lazyRunStatements.append(stmt)
    }
    
    internal func makeSubContext() -> XCTLRuntimeAbstractContext {
        return XCTLRuntimeSubContext(parent: self)
    }
    
}
