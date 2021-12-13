//
//  QNColorItem.m
//  Helloworld
//
//  Created by zhiyunyu on 2020/3/6.
//  Copyright © 2020 zhiyunyu. All rights reserved.
//

#import "QNColorItem.h"

@interface QNColorItem ()

@property(nonatomic, strong) UIColor *color;
@property(nonatomic, assign) NSInteger percent;
@property(nonatomic, assign) NSInteger pixelCount;

@end

@implementation QNColorItem

- (instancetype)initWithColor:(UIColor *)color
                      percent:(NSInteger)percent
                   pixelCount:(NSInteger)pixelCount {
    self = [super init];
    if (self) {
        self.color = color;
        self.percent = percent;
        self.pixelCount = pixelCount;
    }
    return self;
}

@end
