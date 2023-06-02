//
//  XCTLRuntimeTypeInstance.h
//  XCTreeLang
//
//  Created by 邢铖 on 2023/6/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XCTLRuntimeTypeInstance : NSObject

+ (instancetype)makeNativeUseMetaType:(id)metaType runtimeContext:(id)context;

- (id)metaTypeForSelf;

@end

NSException * _Nullable ocTryCatch(void(^tryBlock)(void));

NS_ASSUME_NONNULL_END
