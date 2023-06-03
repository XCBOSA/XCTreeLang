//
//  XCTLInvocation.h
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XCTLInvocation : NSObject

- (instancetype)initWithObject:(NSObject *)object forSelector:(SEL)selector;

- (NSInteger)numberOfArguments;
- (NSString *)typeEncodingForArgumentAtIndex:(NSInteger)index;
- (void)setRawArgument:(void *)rawPointer atIndex:(NSInteger)index;
- (void)setArgument_c:(char)value atIndex:(NSInteger)index;
- (void)setArgument_s:(short)value atIndex:(NSInteger)index;
- (void)setArgument_i:(int)value atIndex:(NSInteger)index;
- (void)setArgument_q:(long long)value atIndex:(NSInteger)index;
- (void)setArgument_C:(unsigned char)value atIndex:(NSInteger)index;
- (void)setArgument_S:(unsigned short)value atIndex:(NSInteger)index;
- (void)setArgument_I:(unsigned int)value atIndex:(NSInteger)index;
- (void)setArgument_Q:(unsigned long long)value atIndex:(NSInteger)index;
- (void)setArgument_L:(unsigned long)value atIndex:(NSInteger)index;
- (void)setArgument_f:(float)value atIndex:(NSInteger)index;
- (void)setArgument_d:(double)value atIndex:(NSInteger)index;
- (void)setArgument_B:(bool)value atIndex:(NSInteger)index;
- (void)setArgument_star:(NSString *)value atIndex:(NSInteger)index;
- (void)setArgument_at:(NSObject *)value atIndex:(NSInteger)index;

- (void)invoke;

- (NSString *)methodReturnType;
- (char)getReturnValue_c;
- (short)getReturnValue_s;
- (int)getReturnValue_i;
- (long long)getReturnValue_q;
- (unsigned char)getReturnValue_C;
- (unsigned short)getReturnValue_S;
- (unsigned int)getReturnValue_I;
- (unsigned long long)getReturnValue_Q;
- (unsigned long)getReturnValue_L;
- (float)getReturnValue_F;
- (double)getReturnValue_D;
- (bool)getReturnValue_B;
- (NSString *)getReturnValue_star;
- (NSObject *)getReturnValue_at;

@end

NS_ASSUME_NONNULL_END
