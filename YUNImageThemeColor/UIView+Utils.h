//
//  UIView+Utils.h
//  Helloworld
//
//  Created by zhiyunyu on 2019/4/17.
//  Copyright © 2019 zhiyunyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Utils)

@property(nonatomic /* override */) CGFloat qn_left;

@property(nonatomic /* override */) CGFloat qn_top;

@property(nonatomic /* override */) CGFloat qn_right;

@property(nonatomic /* override */) CGFloat qn_bottom;

@property(nonatomic /* override */) CGFloat qn_width;

@property(nonatomic /* override */) CGFloat qn_height;

@property(nonatomic /* override */) CGFloat qn_centerX;

@property(nonatomic /* override */) CGFloat qn_centerY;


@end

NS_ASSUME_NONNULL_END
