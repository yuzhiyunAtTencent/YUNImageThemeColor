//
//  UIView+Utils.m
//  Helloworld
//
//  Created by zhiyunyu on 2019/4/17.
//  Copyright © 2019 zhiyunyu. All rights reserved.
//

#import "UIView+Utils.h"

@implementation UIView (Utils)

- (CGFloat)qn_left {
    return self.frame.origin.x;
}

- (void)setQn_left:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)qn_top {
    return self.frame.origin.y;
}

- (void)setQn_top:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)qn_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setQn_right:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)qn_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setQn_bottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)qn_centerX {
    return self.center.x;
}

- (void)setQn_centerX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)qn_centerY {
    return self.center.y;
}

- (void)setQn_centerY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)qn_width {
    return self.frame.size.width;
}

- (void)setQn_width:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)qn_height {
    return self.frame.size.height;
}

- (void)setQn_height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

@end
