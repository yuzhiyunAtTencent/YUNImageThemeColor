//
//  QNColorTransformer.h
//  Helloworld
//
//  Created by zhiyunyu on 2020/3/5.
//  Copyright © 2020 zhiyunyu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define QUANTIZE_WORD_WIDTH 5

/**
 切换颜色位数
 从 RBG8 裁剪到 RGB5
 从 RBG5 恢复到 RGB8
 */

@interface QNColorTransformer : NSObject

+ (NSInteger)quantizedRed:(NSInteger)color;

+ (NSInteger)quantizedGreen:(NSInteger)color;

+ (NSInteger)quantizedBlue:(NSInteger)color;

+ (NSInteger)modifyWordWidthWithValue:(NSInteger)value currentWidth:(NSInteger)currentWidth targetWidth:(NSInteger)targetWidth;

@end

NS_ASSUME_NONNULL_END
