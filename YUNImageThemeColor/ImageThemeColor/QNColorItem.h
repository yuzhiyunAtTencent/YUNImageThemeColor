//
//  QNColorItem.h
//  Helloworld
//
//  Created by zhiyunyu on 2020/3/6.
//  Copyright © 2020 zhiyunyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNColorItem : NSObject

@property(nonatomic, strong, readonly) UIColor *color;
@property(nonatomic, assign, readonly) NSInteger percent;
@property(nonatomic, assign, readonly) NSInteger pixelCount;
// warning zhiyun 仅用于调试
@property(nonatomic, assign) BOOL isPureColor;

- (instancetype)initWithColor:(UIColor *)color
                      percent:(NSInteger)percent
                   pixelCount:(NSInteger)pixelCount;

@end

NS_ASSUME_NONNULL_END
