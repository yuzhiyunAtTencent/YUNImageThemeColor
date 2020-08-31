//
//  QNColorBox.h
//  Helloworld
//
//  Created by zhiyunyu on 2020/3/5.
//  Copyright © 2020 zhiyunyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>
#import "QNColorTransformer.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,COMPONENT_COLOR){
    COMPONENT_RED = 0,
    COMPONENT_GREEN = 1,
    COMPONENT_BLUE = 2
};

@interface QNColorBox : NSObject

@property(nonatomic, assign) BOOL shouldParticipateInVolumeSort;
@property(nonatomic, assign) BOOL isPureColor;

- (NSInteger)pixelTotalCount;

- (UIColor *)getAverageColor;

- (instancetype)initWithLowerIndex:(NSInteger)lowerIndex
                        upperIndex:(NSInteger)upperIndex
                        colorArray:(NSMutableArray *)colorArray
                              hist:(int *)hist;

- (NSInteger)getVolume;

- (QNColorBox *)splitBox;

// 对_distinctColors数组进行排序，数组内存储的是hist的横坐标，也就是具体的颜色值
- (void)sortColorArray;

- (BOOL)canSplit;

- (void)calculateAverageColor;

@end

NS_ASSUME_NONNULL_END
