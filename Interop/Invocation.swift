//
//  Dynamic
//  Created by Mhd Hejazi on 4/15/20.
//  Modify by XCBOSA on 6/3/23
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

class Invocation {
    public static var loggingEnabled: Bool = false

    private let target: NSObject
    private let selector: Selector

    var invocation: NSObject?

    var typeEncoding: String?
    var numberOfArguments: Int = 0
    var returnLength: Int = 0
    var returnType: UnsafePointer<CChar>?
    var returnTypeString: String? {
        guard let returnType = returnType else { return nil }
        return String(cString: returnType)
    }
    var returnsObject: Bool {
        /// `@` is the type encoding for an object
        returnTypeString == "@"
    }
    var returnsAny: Bool {
        /// `v` is the type encoding for Void
        returnTypeString != "v"
    }
    lazy var returnedObject: AnyObject? = {
        returnedObjectValue()
    }()
    private(set) var isInvoked: Bool = false

    init(target: NSObject, selector: Selector) throws {
        self.target = target
        self.selector = selector
        try initialize()
    }

    private func initialize() throws {
        /// `NSMethodSignature *methodSignature = [target methodSignatureForSelector: selector]`
        let methodSignature: NSObject
        do {
            let selector = NSSelectorFromString("methodSignatureForSelector:")
            let signature = (@convention(c)(NSObject, Selector, Selector) -> Any).self
            let method = unsafeBitCast(target.method(for: selector), to: signature)
            guard let result = method(target, selector, self.selector) as? NSObject else {
                let error = InvocationError.unrecognizedSelector(type(of: target), self.selector)
                throw error
            }
            methodSignature = result
        }

        /// `numberOfArguments = methodSignature.numberOfArguments`
        self.numberOfArguments = methodSignature.value(forKeyPath: "numberOfArguments") as? Int ?? 0

        /// `methodReturnLength = methodSignature.methodReturnLength`
        self.returnLength = methodSignature.value(forKeyPath: "methodReturnLength") as? Int ?? 0

        /// `methodReturnType = methodSignature.methodReturnType`
        let methodReturnType: UnsafePointer<CChar>
        do {
            let selector = NSSelectorFromString("methodReturnType")
            let signature = (@convention(c)(NSObject, Selector) -> UnsafePointer<CChar>).self
            let method = unsafeBitCast(methodSignature.method(for: selector), to: signature)
            methodReturnType = method(methodSignature, selector)
        }
        self.returnType = methodReturnType

        /// `NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: methodSignature]`
        let invocation: NSObject
        do {
            let NSInvocation = NSClassFromString("NSInvocation") as AnyObject
            let selector = NSSelectorFromString("invocationWithMethodSignature:")
            let signature = (@convention(c)(AnyObject, Selector, AnyObject) -> AnyObject).self
            let method = unsafeBitCast(NSInvocation.method(for: selector), to: signature)
            guard let result = method(NSInvocation, selector, methodSignature) as? NSObject else {
                let error = InvocationError.unrecognizedSelector(type(of: target), self.selector)
                throw error
            }
            invocation = result
        }
        self.invocation = invocation

        /// `invocation.selector = selector`
        do {
            let selector = NSSelectorFromString("setSelector:")
            let signature = (@convention(c)(NSObject, Selector, Selector) -> Void).self
            let method = unsafeBitCast(invocation.method(for: selector), to: signature)
            method(invocation, selector, self.selector)
        }

        /// `[invocation retainArguments]`
        do {
            let selector = NSSelectorFromString("retainArguments")
            let signature = (@convention(c)(NSObject, Selector) -> Void).self
            let method = unsafeBitCast(invocation.method(for: selector), to: signature)
            method(invocation, selector)
        }
    }
    
    private func getArgumentType(at index: NSInteger) -> String? {
        guard let invocation = invocation else { return nil }
        
        let methodSignatureSelector = NSSelectorFromString("methodSignature")
        let methodSignatureSignature = (@convention(c)(NSObject, Selector) -> NSObject).self
        let methodSignatureMethod = unsafeBitCast(invocation.method(for: methodSignatureSelector), to: methodSignatureSignature)
        
        let methodSignature = methodSignatureMethod(invocation, methodSignatureSelector)
        
        let selector = NSSelectorFromString("getArgumentTypeAtIndex:")
        let signature = (@convention(c)(NSObject, Selector, NSInteger) -> UnsafePointer<CChar>).self
        let method = unsafeBitCast(methodSignature.method(for: selector), to: signature)
        
        let rawType = method(methodSignature, selector, index)
        return NSString(cString: rawType, encoding: NSUTF8StringEncoding) as? String
    }

    func setArgument(_ argument: Any?, at index: NSInteger) {
        guard let invocation = invocation else { return }
        
        let argument = TypeMapping.convertToObjCType(argument) ?? argument
        guard let realArgumentType = self.getArgumentType(at: index) else { return }

        /// `[invocation setArgument:&argument atIndex:i + 2]`
        let selector = NSSelectorFromString("setArgument:atIndex:")
        let signature = (@convention(c)(NSObject, Selector, UnsafeRawPointer, Int) -> Void).self
        let method = unsafeBitCast(invocation.method(for: selector), to: signature)
        
//        if let valueArgument = argument as? NSNumber {
//            /// Get the type byte size
////            valueArgument = NSNumber(floatLiteral: argument as! Double)
//            let typeSize = UnsafeMutablePointer<Int>.allocate(capacity: 1)
//            defer { typeSize.deallocate() }
//            NSGetSizeAndAlignment(valueArgument.objCType, typeSize, nil)
//
//            /// Get the actual value
//            let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: typeSize.pointee)
//            defer { buffer.deallocate() }
//            valueArgument.getValue(buffer)
//
//            method(invocation, selector, buffer, index)
//        } else {
            withUnsafePointer(to: argument) { pointer in
                method(invocation, selector, pointer, index)
//            }
        }
    }

    func invoke() {
        guard let invocation = invocation, !isInvoked else { return }

        isInvoked = true

        /// `[invocation invokeWithTarget: target]`
        do {
            let selector = NSSelectorFromString("invokeWithTarget:")
            let signature = (@convention(c)(NSObject, Selector, AnyObject) -> Void).self
            let method = unsafeBitCast(invocation.method(for: selector), to: signature)
            method(invocation, selector, target)
        }
    }

    func getReturnValue<T>(result: inout T) {
        guard let invocation = invocation else { return }

        /// `[invocation getReturnValue: returnValue]`
        do {
            let selector = NSSelectorFromString("getReturnValue:")
            let signature = (@convention(c)(NSObject, Selector, UnsafeMutableRawPointer) -> Void).self
            let method = unsafeBitCast(invocation.method(for: selector), to: signature)
            withUnsafeMutablePointer(to: &result) { pointer in
                method(invocation, selector, pointer)
            }
        }
    }

    private func returnedObjectValue() -> AnyObject? {
        guard returnsObject, returnLength > 0 else {
            return nil
        }

        var result: AnyObject?

        getReturnValue(result: &result)

        guard let object = result else {
            return nil
        }

        /// Take the ownership of the initialized objects to ensure they're deallocated properly.
        if isRetainingMethod() {
            return Unmanaged.passRetained(object).takeRetainedValue()
        }

        /// `NSInvocation.getReturnValue()` doesn't give us the ownership of the returned object, but the compiler
        /// tries to release this object anyway. So, we are retaining it to balance with the compiler's release.
        return Unmanaged.passRetained(object).takeUnretainedValue()
    }

    private func isRetainingMethod() -> Bool {
        /// Refer to: https://bit.ly/308okXm
        let selector = NSStringFromSelector(self.selector)
        return selector == "alloc" ||
            selector.hasPrefix("new") ||
            selector.hasPrefix("copy") ||
            selector.hasPrefix("mutableCopy")
    }
}

internal enum InvocationError: CustomNSError {
    case unrecognizedSelector(_ classType: AnyClass, _ selector: Selector)

    internal static var errorDomain: String { String(describing: Invocation.self) }

    internal var errorCode: Int {
        switch self {
        case .unrecognizedSelector:
            return 404
        }
    }

    internal var errorUserInfo: [String: Any] {
        var message: String
        switch self {
        case .unrecognizedSelector(let classType, let selector):
            message = "'\(String(describing: classType))' doesn't recognize selector '\(selector)'"
        }
        return [NSLocalizedDescriptionKey: message]
    }
}
