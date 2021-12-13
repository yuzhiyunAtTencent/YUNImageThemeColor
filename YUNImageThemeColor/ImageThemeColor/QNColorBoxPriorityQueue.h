//
//  QNColorBoxPriorityQueue.h
//  Helloworld
//
//  Created by zhiyunyu on 2020/3/5.
//  Copyright © 2020 zhiyunyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QNColorBox.h"

NS_ASSUME_NONNULL_BEGIN

// 经过这个commit优化后，获取到的主题色会更加接近真正想要的颜色，并且如果业务层需要获取各种颜色的分布比例的话，可以调大这个数字
//以本demo的皮卡丘图片为例，调到64就会清晰的解析出黄色和红色
#define QN_THEHE_COLOR_MAX_COUNT  64

@interface QNColorBoxPriorityQueue : NSObject

- (void)addColorBox:(QNColorBox *)box;

- (QNColorBox *)objectAtIndex:(NSInteger)i;

- (QNColorBox *)poll;

- (NSUInteger)count;

- (NSMutableArray*)getColorBoxArray;

@end

NS_ASSUME_NONNULL_END
