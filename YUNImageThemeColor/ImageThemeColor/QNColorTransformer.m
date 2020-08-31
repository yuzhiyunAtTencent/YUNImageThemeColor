//
//  QNColorTransformer.m
//  Helloworld
//
//  Created by zhiyunyu on 2020/3/5.
//  Copyright © 2020 zhiyunyu. All rights reserved.
//

#import "QNColorTransformer.h"

const NSInteger QUANTIZE_WORD_WIDTH_COLOR = 5;
const NSInteger QUANTIZE_WORD_MASK_COLOR = (1 << QUANTIZE_WORD_WIDTH_COLOR) - 1;

@implementation QNColorTransformer

+ (NSInteger)quantizedRed:(NSInteger)color{
    NSInteger red =  (color >> (QUANTIZE_WORD_WIDTH_COLOR + QUANTIZE_WORD_WIDTH_COLOR)) & QUANTIZE_WORD_MASK_COLOR;
    return red;
}

+ (NSInteger)quantizedGreen:(NSInteger)color{
    NSInteger green = (color >> QUANTIZE_WORD_WIDTH_COLOR) & QUANTIZE_WORD_MASK_COLOR;
    return green;
}

+ (NSInteger)quantizedBlue:(NSInteger)color{
    NSInteger blue = color & QUANTIZE_WORD_MASK_COLOR;
    return blue;
}

+ (NSInteger)modifyWordWidthWithValue:(NSInteger)value currentWidth:(NSInteger)currentWidth targetWidth:(NSInteger)targetWidth{
    NSInteger newValue;
    if (targetWidth > currentWidth) {
        // If we're approximating up in word width, we'll use scaling to approximate the
        // new value
        newValue = value * ((1 << targetWidth) - 1) / ((1 << currentWidth) - 1);
    } else {
        // Else, we will just shift and keep the MSB
        newValue = value >> (currentWidth - targetWidth);
    }
    return newValue & ((1 << targetWidth) - 1);
}

@end
