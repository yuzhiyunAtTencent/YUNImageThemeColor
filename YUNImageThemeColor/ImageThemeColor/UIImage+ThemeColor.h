//
//  UIImage+ThemeColor.h
//  Helloworld
//
//  Created by zhiyunyu on 2020/3/5.
//  Copyright © 2020 zhiyunyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QNThemeColorExtracter.h"
#import "QNColorItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ThemeColor)

- (void)getThemeColor:(QNGetColorBlock)block;

@end

NS_ASSUME_NONNULL_END
