//
//  XCTLEngine.swift
//  notebook
//
//  Created by 邢铖 on 2023/5/18.
//

import Foundation
import UIKit

@objcMembers
public class XCTLAST: NSObject {
    
    fileprivate let rootStatement: XCTLStatement
    
    fileprivate let paragraphMembers: [String : XCTLStatement]
    
    fileprivate init(rootStatement ast: XCTLStatement, paragraphMembers: [String : XCTLStatement]) {
        self.rootStatement = ast
        self.paragraphMembers = paragraphMembers
    }
    
    public weak var stdoutDelegate: XCTLStreamDelegate?
    
}

@objcMembers
public class XCTLEngine: NSObject {
    
    public static var shared: XCTLEngine = XCTLEngine()
    
    private static var debugMode: Bool = false
    
    private var prototypes = [String : XCTLGenerateProtocol.Type]()
    
    private func getClassesImplementingProtocol(p: Protocol) -> [AnyClass] {
        let classes = objc_getClassList()
        var ret = [AnyClass]()

        for cls in classes {
            if class_conformsToProtocol(cls, p) {
                ret.append(cls)
            }
        }
        return ret
    }

    private func objc_getClassList() -> [AnyClass] {
        let expectedClassCount = ObjectiveC.objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount:Int32 = ObjectiveC.objc_getClassList(autoreleasingAllClasses, expectedClassCount)

        var classes = [AnyClass]()
        for i in 0 ..< actualClassCount {
            if let currentClass: AnyClass = allClasses[Int(i)] {
                classes.append(currentClass)
            }
        }
        allClasses.deallocate()
        return classes
    }
    
    private override init() {
        super.init()
        let classes = getClassesImplementingProtocol(p: XCTLGenerateProtocol.self)
        for it in classes {
            self.prototypes["\(it)"] = it as? any XCTLGenerateProtocol.Type
            if Self.debugMode {
                print("[XCTInitializer] \(it)")
            }
        }
    }
    
    public func compile(fileNameWithoutExtension xct: String) -> XCTLAST? {
        guard let path = Bundle.main.path(forResource: xct, ofType: ".xct") else {
            print("no such file \(xct)")
            return nil
        }
        return compile(fullFilePath: path)
    }
    
    public func compile(fullFilePath xct: String) -> XCTLAST? {
        guard FileManager.default.fileExists(atPath: xct) else {
            print("no such file \(xct)")
            return nil
        }
        do {
            let code = try String(contentsOfFile: xct)
            return self.compile(code: code)
        } catch let err {
            print(err)
            return nil
        }
    }
    
    public func compile(code: String) -> XCTLAST? {
        do {
            let lexer = XCTLLexer(document: code)
            lexer.debugMode = Self.debugMode
            let rootStatement = XCTLRootStatement()
            try rootStatement.parseStatement(fromLexerToSelf: lexer, fromParent: nil)
            return XCTLAST(rootStatement: rootStatement, paragraphMembers: lexer.paragraphTable)
        } catch let err {
            print(err)
            return nil
        }
    }
    
    public func evaluate(ast: XCTLAST, sourceObject: NSObject) throws {
        let rootStatement = ast.rootStatement
        let context = XCTLRuntimeContext(nativeObjectInstance: sourceObject,
                                         paragraphMembers: ast.paragraphMembers,
                                         generators: prototypes)
        context.stdout.delegate = ast.stdoutDelegate
        _ = try rootStatement.evaluate(inContext: context)
        for it in context.lazyRunStatements {
            _ = try it.evaluate(inContext: context)
        }
    }
    
    public func enableAutoEvaluateForViewController() {
        let originalViewDidLoad = #selector(UIViewController.viewDidLoad)
        let swizzledViewDidLoad = #selector(UIViewController.swizzledXCTLEngineViewDidLoad)
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalViewDidLoad),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledViewDidLoad) else {
            fatalError("Can not inject XCTLEngine to UIViewController")
        }
        let originalImp = method_getImplementation(originalMethod)
        let originalTypeEncoding = method_getTypeEncoding(originalMethod)
        class_addMethod(UIViewController.self,
                        NSSelectorFromString("UIViewController.originalViewDidLoad"),
                        originalImp,
                        originalTypeEncoding)
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
}

public extension UIViewController {
    
    @objc func swizzledXCTLEngineViewDidLoad() {
        let className = "\(self.classForCoder)"
        if let xctFile = Bundle.main.path(forResource: className, ofType: "xct") {
            print("[XCTLEngine-ScanClass] Execute disk file \(className).xct")
            let time = Date()
            guard let ast = XCTLEngine.shared.compile(fullFilePath: xctFile) else {
                fatalError("Unable to compile XCT file \(xctFile)")
            }
            do {
                try XCTLEngine.shared.evaluate(ast: ast, sourceObject: self)
            } catch let error {
                fatalError("Runtime error when execute XCT file \(xctFile): \(error)")
            }
            print("[XCTLEngine-ScanClass] Finish execute \(className).xct in \(time.distance(to: Date())) seconds")
        }
        self.perform(NSSelectorFromString("UIViewController.originalViewDidLoad"))
    }
    
}
