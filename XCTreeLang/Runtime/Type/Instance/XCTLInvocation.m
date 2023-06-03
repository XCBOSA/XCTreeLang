//
//  XCTLInvocation.m
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/3.
//

#import "XCTLInvocation.h"

typedef union {
    char c;
    short s;
    int i;
    long l;
    long long q;
    unsigned char C;
    unsigned short S;
    unsigned int I;
    unsigned long L;
    unsigned long long Q;
    float f;
    double d;
    bool B;
    char buff1[1];
    char buff2[2];
    char buff4[4];
    char buff8[8];
    void *pointer;
} XCTLStackableObject;

@interface XCTLInvocation ()

@property (strong) NSObject *target;
@property (strong) NSInvocation *invocation;
@property (strong) NSMethodSignature *methodSignature;
@property (assign) char *returnValueBuffer;

@end

@implementation XCTLInvocation

- (instancetype)initWithObject:(NSObject *)object forSelector:(SEL)selector {
    self = [super init];
    self.target = object;
    self.methodSignature = [object methodSignatureForSelector:selector];
    self.invocation = [NSInvocation invocationWithMethodSignature:self.methodSignature];
    self.invocation.selector = selector;
    [self.invocation retainArguments];
    return self;
}

- (NSInteger)numberOfArguments {
    return self.methodSignature.numberOfArguments;
}

- (NSString *)typeEncodingForArgumentAtIndex:(NSInteger)index {
    const char *encoding = [self.methodSignature getArgumentTypeAtIndex:index];
    return [NSString stringWithCString:encoding encoding:NSUTF8StringEncoding];
}

- (NSString *)methodReturnType {
    return [NSString stringWithCString:self.methodSignature.methodReturnType encoding:NSUTF8StringEncoding];
}

- (void)setRawArgument:(void *)rawPointer atIndex:(NSInteger)index {
    [self.invocation setArgument:rawPointer atIndex:index];
}

- (void)setArgument_c:(char)value atIndex:(NSInteger)index {
    XCTLStackableObject obj;
    obj.c = value;
    [self setRawArgument:obj.buff1 atIndex:index];
}

- (void)setArgument_s:(short)value atIndex:(NSInteger)index {
    XCTLStackableObject obj;
    obj.s = value;
    [self setRawArgument:obj.buff2 atIndex:index];
}

- (void)setArgument_i:(int)value atIndex:(NSInteger)index {
    XCTLStackableObject obj;
    obj.i = value;
    [self setRawArgument:obj.buff4 atIndex:index];
}

- (void)setArgument_q:(long long)value atIndex:(NSInteger)index {
    XCTLStackableObject obj;
    obj.q = value;
    [self setRawArgument:obj.buff8 atIndex:index];
}

- (void)setArgument_C:(unsigned char)value atIndex:(NSInteger)index {
    XCTLStackableObject obj;
    obj.C = value;
    [self setRawArgument:obj.buff1 atIndex:index];
}

- (void)setArgument_S:(unsigned short)value atIndex:(NSInteger)index {
    XCTLStackableObject obj;
    obj.S = value;
    [self setRawArgument:obj.buff2 atIndex:index];
}

- (void)setArgument_I:(unsigned int)value atIndex:(NSInteger)index {
    XCTLStackableObject obj;
    obj.I = value;
    [self setRawArgument:obj.buff4 atIndex:index];
}

- (void)setArgument_Q:(unsigned long long)value atIndex:(NSInteger)index {
    XCTLStackableObject obj;
    obj.Q = value;
    [self setRawArgument:obj.buff8 atIndex:index];
}

- (void)setArgument_L:(unsigned long)value atIndex:(NSInteger)index {
    XCTLStackableObject obj;
    obj.L = value;
    [self setRawArgument:obj.buff4 atIndex:index];
}

- (void)setArgument_f:(float)value atIndex:(NSInteger)index {
    XCTLStackableObject obj;
    obj.f = value;
    [self setRawArgument:obj.buff4 atIndex:index];
}

- (void)setArgument_d:(double)value atIndex:(NSInteger)index {
    XCTLStackableObject obj;
    obj.d = value;
    [self setRawArgument:obj.buff8 atIndex:index];
}

- (void)setArgument_B:(bool)value atIndex:(NSInteger)index {
    XCTLStackableObject obj;
    obj.B = value;
    [self setRawArgument:obj.buff1 atIndex:index];
}

- (void)setArgument_star:(NSString *)value atIndex:(NSInteger)index {
    const char *cString = [value cStringUsingEncoding:NSUTF8StringEncoding];
    [self setRawArgument:(char *)cString atIndex:index];
}

- (void)setArgument_at:(NSObject *)value atIndex:(NSInteger)index {
    [self setRawArgument:&value atIndex:index];
}

- (void)invoke {
    [self.invocation invokeWithTarget:self.target];
    if (self.methodSignature.methodReturnLength) {
        self.returnValueBuffer = calloc(self.methodSignature.methodReturnLength, sizeof(char));
        [self.invocation getReturnValue:self.returnValueBuffer];
    }
}

- (char)getReturnValue_c {
    XCTLStackableObject obj;
    memcpy(obj.buff1, self.returnValueBuffer, 1);
    return obj.c;
}

- (short)getReturnValue_s {
    XCTLStackableObject obj;
    memcpy(obj.buff2, self.returnValueBuffer, 2);
    return obj.s;
}

- (int)getReturnValue_i {
    XCTLStackableObject obj;
    memcpy(obj.buff4, self.returnValueBuffer, 4);
    return obj.i;
}

- (long long)getReturnValue_q {
    XCTLStackableObject obj;
    memcpy(obj.buff8, self.returnValueBuffer, 8);
    return obj.q;
}

- (unsigned char)getReturnValue_C {
    XCTLStackableObject obj;
    memcpy(obj.buff1, self.returnValueBuffer, 1);
    return obj.C;
}

- (unsigned short)getReturnValue_S {
    XCTLStackableObject obj;
    memcpy(obj.buff2, self.returnValueBuffer, 2);
    return obj.S;
}

- (unsigned int)getReturnValue_I {
    XCTLStackableObject obj;
    memcpy(obj.buff4, self.returnValueBuffer, 4);
    return obj.I;
}

- (unsigned long long)getReturnValue_Q {
    XCTLStackableObject obj;
    memcpy(obj.buff8, self.returnValueBuffer, 8);
    return obj.Q;
}

- (unsigned long)getReturnValue_L {
    XCTLStackableObject obj;
    memcpy(obj.buff4, self.returnValueBuffer, 4);
    return obj.L;
}

- (float)getReturnValue_F {
    XCTLStackableObject obj;
    memcpy(obj.buff4, self.returnValueBuffer, 4);
    return obj.f;
}

- (double)getReturnValue_D {
    XCTLStackableObject obj;
    memcpy(obj.buff8, self.returnValueBuffer, 8);
    return obj.d;
}

- (bool)getReturnValue_B {
    XCTLStackableObject obj;
    memcpy(obj.buff1, self.returnValueBuffer, 1);
    return obj.B;
}

- (NSString *)getReturnValue_star {
    XCTLStackableObject obj;
    memcpy(obj.buff8, self.returnValueBuffer, 8);
    const char *pointer = obj.pointer;
    return [NSString stringWithCString:pointer encoding:NSUTF8StringEncoding];
}

- (NSObject *)getReturnValue_at {
    XCTLStackableObject obj;
    memcpy(obj.buff8, self.returnValueBuffer, 8);
    const void *pointer = obj.pointer;
    return (__bridge NSObject *)pointer;
}


@end
