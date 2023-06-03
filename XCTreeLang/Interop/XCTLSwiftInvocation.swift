//
//  XCTLSwiftInvocation.swift
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/3.
//

import Foundation
import XCTLRuntimeTypeInstanceModule

public class XCTLSwiftInvocation {
    
    private let invocation: XCTLInvocation
    
    public init(target: NSObject, selector: Selector) {
        self.invocation = XCTLInvocation(object: target, for: selector)
    }
    
    public func invokeMemberFunc(params: [Any?]) throws -> Any {
        var id = 2
        if self.invocation.numberOfArguments() != params.count + 2 {
            throw XCTLRuntimeError.paragraphArgsNotEnough(needCount: self.invocation.numberOfArguments() - 2, butGot: params.count)
        }
        for it in params {
            let type = self.invocation.typeEncodingForArgument(at: id)
            switch type {
            case "c":
                guard let ch = (it as? String)?.utf8.first else {
                    throw XCTLRuntimeError.callingTypeEncodingError
                }
                self.invocation.setArgument_c(CChar(ch), at: id)
                break
            case "s":
                guard let double = it as? Double else {
                    throw XCTLRuntimeError.callingTypeEncodingError
                }
                self.invocation.setArgument_s(Int16(double), at: id)
                break
            case "i":
                guard let double = it as? Double else {
                    throw XCTLRuntimeError.callingTypeEncodingError
                }
                self.invocation.setArgument_i(Int32(double), at: id)
                break
            case "q":
                guard let double = it as? Double else {
                    throw XCTLRuntimeError.callingTypeEncodingError
                }
                self.invocation.setArgument_q(Int64(double), at: id)
                break
            case "C":
                guard let ch = (it as? String)?.utf8.first else {
                    throw XCTLRuntimeError.callingTypeEncodingError
                }
                self.invocation.setArgument_C(UInt8(ch), at: id)
                break
            case "S":
                guard let double = it as? Double else {
                    throw XCTLRuntimeError.callingTypeEncodingError
                }
                self.invocation.setArgument_S(UInt16(double), at: id)
                break
            case "I":
                guard let double = it as? Double else {
                    throw XCTLRuntimeError.callingTypeEncodingError
                }
                self.invocation.setArgument_I(UInt32(double), at: id)
                break
            case "Q":
                guard let double = it as? Double else {
                    throw XCTLRuntimeError.callingTypeEncodingError
                }
                self.invocation.setArgument_Q(UInt64(double), at: id)
                break
            case "L":
                guard let double = it as? Double else {
                    throw XCTLRuntimeError.callingTypeEncodingError
                }
                self.invocation.setArgument_L(UInt(double), at: id)
                break
            case "f":
                guard let double = it as? Double else {
                    throw XCTLRuntimeError.callingTypeEncodingError
                }
                self.invocation.setArgument_f(Float(double), at: id)
                break
            case "d":
                guard let double = it as? Double else {
                    throw XCTLRuntimeError.callingTypeEncodingError
                }
                self.invocation.setArgument_d(double, at: id)
                break
            case "B":
                guard let bool = it as? Bool else {
                    throw XCTLRuntimeError.callingTypeEncodingError
                }
                self.invocation.setArgument_B(bool, at: id)
                break
            case "*":
                guard let string = it as? String else {
                    throw XCTLRuntimeError.callingTypeEncodingError
                }
                self.invocation.setArgument_star(string, at: id)
                break
            case "@":
                guard let object = it as? NSObject else {
                    throw XCTLRuntimeError.callingTypeEncodingError
                }
                self.invocation.setArgument_at(object, at: id)
                break
            default:
                throw XCTLRuntimeError.unknownTypeEncoding(name: type)
            }
            id += 1
        }
        self.invocation.invoke()
        switch self.invocation.methodReturnType() {
        case "v":
            return NSNull()
        case "c":
            return self.invocation.getReturnValue_c()
        case "s":
            return self.invocation.getReturnValue_s()
        case "i":
            return self.invocation.getReturnValue_i()
        case "q":
            return self.invocation.getReturnValue_q()
        case "C":
            return self.invocation.getReturnValue_C()
        case "S":
            return self.invocation.getReturnValue_S()
        case "I":
            return self.invocation.getReturnValue_I()
        case "Q":
            return self.invocation.getReturnValue_Q()
        case "L":
            return self.invocation.getReturnValue_L()
        case "f":
            return self.invocation.getReturnValue_F()
        case "d":
            return self.invocation.getReturnValue_D()
        case "B":
            return self.invocation.getReturnValue_B()
        case "*":
            return self.invocation.getReturnValue_star()
        case "@":
            return self.invocation.getReturnValue_at()
        default:
            throw XCTLRuntimeError.unknownTypeEncoding(name: self.invocation.methodReturnType())
        }
    }
    
}
