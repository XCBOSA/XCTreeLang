//
//  XCTLRuntimeTypeInstance.m
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/2.
//

#import "XCTLRuntimeTypeInstance.h"
#import <XCTreeLang/XCTreeLang-Swift.h>

extern const int methodIMPSlotCnt;
extern const IMP methodIMPSlotR[9];
extern const char methodIMPSoltRType[9][20];
extern id variableGetterMethodIMP(id self, SEL aSelector);
extern void variableSetterMethodIMP(id self, SEL aSelector, id newValue);

@interface XCTLRuntimeTypeInstance ()

@property (nonatomic, assign) BOOL alreadyMakeNativeType;

@property (nonatomic, weak) XCTLRuntimeType *metaType;
@property (nonatomic, strong) id runtimeContext;
@property (nonatomic, copy) NSArray<XCTLRuntimeFunctionDef *> *runtimeFuncDefs;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *runtimeTypeNameWithClasses;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSObject *> *runtimeVariables;
@property (nonatomic, assign) Class klass;

@end

@implementation XCTLRuntimeTypeInstance

+ (instancetype)makeNativeUseMetaType:(id)metaType runtimeContext:(id)context {
    XCTLRuntimeType *meta = metaType;
    Class klass = objc_duplicateClass(self.class,
                                      [[meta.runtimeClassName stringByAppendingFormat:@"_Sub_%p", self] cStringUsingEncoding:NSUTF8StringEncoding],
                                      0);
    XCTLRuntimeTypeInstance *instance = class_createInstance(klass, 0);
    instance = [instance initWithMetaType:meta
                        andRuntimeContext:context
                               onSubClass:klass];
    [instance makeNativeType];
    return instance;
}

- (instancetype)initWithMetaType:(XCTLRuntimeType *)metaType
               andRuntimeContext:(id)context
                      onSubClass:(Class)klass {
    self = [super init];
    self.metaType = metaType;
    self.runtimeContext = context;
    self.klass = klass;
    return self;
}

- (NSMutableDictionary<NSString *,NSObject *> *)runtimeVariables {
    if (!_runtimeVariables) {
        _runtimeVariables = [NSMutableDictionary new];
    }
    return _runtimeVariables;
}

- (id)metaTypeForSelf {
    return self.metaType;
}

- (void)makeNativeType {
    if (self.alreadyMakeNativeType) {
        return;
    }
    self.alreadyMakeNativeType = true;
    
    self.runtimeTypeNameWithClasses = [self.metaType makeVariableTable];
    for (NSString *key in self.runtimeTypeNameWithClasses) {
        self.runtimeVariables[key] = NSNull.null;
        class_addMethod(self.klass,
                        NSSelectorFromString(key),
                        (IMP)variableGetterMethodIMP,
                        "@@:");
    }
    
    self.runtimeFuncDefs = [self.metaType makeRuntimeFuncDef];
    for (XCTLRuntimeFunctionDef *def in self.runtimeFuncDefs) {
        if (def.argumentCount > methodIMPSlotCnt - 1) {
            NSLog(@"Can not create native function for %@: %ld arguments, max %d", def.selector, (long)def.argumentCount, methodIMPSlotCnt - 1);
        }
        class_addMethod(self.klass,
                        NSSelectorFromString(def.selector),
                        methodIMPSlotR[def.argumentCount],
                        methodIMPSoltRType[def.argumentCount]);
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    NSString *selector = NSStringFromSelector(aSelector);
    for (XCTLRuntimeFunctionDef *def in self.runtimeFuncDefs) {
        if ([def.selector isEqualToString:selector]) {
            return true;
        }
    }
    return false;
}

- (id)valueForKey:(NSString *)key {
    NSObject *anyObject = self.runtimeVariables[key];
    if (anyObject == nil) {
        return [super valueForKey:key];
    }
    return anyObject;
}

@end

id variableGetterMethodIMP(id self, SEL aSelector) {
    return NSNull.null;
}

void variableSetterMethodIMP(id self, SEL aSelector, id newValue) {
    return;
}

static id methodIMPSlot0R(id self, SEL aSelector) {
    return NSNull.null;
}

static id methodIMPSlot1R(id self, SEL aSelector, id obj0) {
    return NSNull.null;
}

static id methodIMPSlot2R(id self, SEL aSelector, id obj0, id obj1) {
    return NSNull.null;
}

static id methodIMPSlot3R(id self, SEL aSelector, id obj0, id obj1, id obj2) {
    return NSNull.null;
}

static id methodIMPSlot4R(id self, SEL aSelector, id obj0, id obj1, id obj2, id obj3) {
    return NSNull.null;
}

static id methodIMPSlot5R(id self, SEL aSelector, id obj0, id obj1, id obj2, id obj3, id obj4) {
    return NSNull.null;
}

static id methodIMPSlot6R(id self, SEL aSelector, id obj0, id obj1, id obj2, id obj3, id obj4, id obj5) {
    return NSNull.null;
}

static id methodIMPSlot7R(id self, SEL aSelector, id obj0, id obj1, id obj2, id obj3, id obj4, id obj5, id obj6) {
    return NSNull.null;
}

static id methodIMPSlot8R(id self, SEL aSelector, id obj0, id obj1, id obj2, id obj3, id obj4, id obj5, id obj6, id obj7) {
    return NSNull.null;
}
    
const int methodIMPSlotCnt = 9;

const IMP methodIMPSlotR[methodIMPSlotCnt] = {
    (IMP)methodIMPSlot0R, (IMP)methodIMPSlot1R, (IMP)methodIMPSlot2R, (IMP)methodIMPSlot3R, (IMP)methodIMPSlot4R,
    (IMP)methodIMPSlot5R, (IMP)methodIMPSlot6R, (IMP)methodIMPSlot7R, (IMP)methodIMPSlot8R
};

const char methodIMPSoltRType[methodIMPSlotCnt][20] = {
    "@@:", "@@:@", "@@:@@", "@@:@@@", "@@:@@@@", "@@:@@@@@", "@@:@@@@@@", "@@:@@@@@@@", "@@:@@@@@@@@"
};

NSException * _Nullable ocTryCatch(void(^tryBlock)(void)) {
    @try {
        tryBlock();
        CGRect s;
        return nil;
    }
    @catch (NSException *exception) {
        return exception;
    }
}
