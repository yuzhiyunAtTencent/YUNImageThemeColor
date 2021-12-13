//
//  QNThemeColor.h
//  Helloworld
//
//  Created by zhiyunyu on 2020/3/5.
//  Copyright © 2020 zhiyunyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QNColorItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^QNGetColorBlock)(NSDictionary<NSString *, QNColorItem *> *colorDic);

@interface QNThemeColorExtracter : NSObject

- (void)extractColorsFromImage:(UIImage *)image
                    colorBlock:(QNGetColorBlock)colorBlock;

@end

NS_ASSUME_NONNULL_END
