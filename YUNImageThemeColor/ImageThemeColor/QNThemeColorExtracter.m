//
//  QNThemeColor.m
//  Helloworld
//
//  Created by zhiyunyu on 2020/3/5.
//  Copyright © 2020 zhiyunyu. All rights reserved.
//

#import "QNThemeColorExtracter.h"
#import "QNColorTransformer.h"
#import "QNColorBox.h"
#import "QNColorBoxPriorityQueue.h"


static int colorHistGram[32768]; // 2^15   一张图片对应的颜色直方图，index代表颜色值，value代表这个颜色值的像素点数量
static dispatch_queue_t imageColorQueue;

@interface QNThemeColorExtracter ()

@property(nonatomic, strong) UIImage *image;
@property(nonatomic, assign) NSInteger pixelCount;
@property(nonatomic, strong) NSMutableArray *distinctColors;
@property(nonatomic, strong) QNColorBoxPriorityQueue *priorityQueue;
@property(nonatomic, strong) NSMutableArray<QNColorItem *> *colorArray;

@end

@implementation QNThemeColorExtracter

- (void)extractColorsFromImage:(UIImage *)image
                    colorBlock:(QNGetColorBlock)colorBlock {
    if (!image) {
        return;
    }

    if (!imageColorQueue) {
        imageColorQueue = dispatch_queue_create("com.tencent.image.themecolor", DISPATCH_QUEUE_SERIAL);
    }
    
    dispatch_async(imageColorQueue, ^{
        self.image = image;
        [self clearHistArray];
        
        unsigned char *rawData = [self rawPixelDataFromImage:image];
        if (!rawData || self.pixelCount <= 0){
            // warning zhiyun 出错了
            return;
        }
        
        NSInteger red,green,blue;
        for (int pixelIndex = 0; pixelIndex < self.pixelCount; pixelIndex++){
            
            red   = (NSInteger)rawData[pixelIndex*4+0];
            green = (NSInteger)rawData[pixelIndex*4+1];
            blue  = (NSInteger)rawData[pixelIndex*4+2];
            
            /* 这一步转换的目的，是缩减hist数组的大小，否则hist的size（也就是直方图横坐标最大值）应该是2^(3*8),现在缩减后，hist的size是2^(3*5)
            2^(3*8) 是如何得出的？ 因为颜色有rgb三种嘛，每种占8bit,比如白色 ffffff 就等于 2^24 - 1
             也就是说只取高5位，低3位就直接抛弃了，这是无所谓的，因为低三位影响很小，111仅仅是7而已
             
             可以把颜色直方图所占的内存从 64M 降低到 128K
             */
            
            red = [QNColorTransformer modifyWordWidthWithValue:red currentWidth:8 targetWidth:QUANTIZE_WORD_WIDTH];
            green = [QNColorTransformer modifyWordWidthWithValue:green currentWidth:8 targetWidth:QUANTIZE_WORD_WIDTH];
            blue = [QNColorTransformer modifyWordWidthWithValue:blue currentWidth:8 targetWidth:QUANTIZE_WORD_WIDTH];
            
            NSInteger quantizedColor = red << 2*QUANTIZE_WORD_WIDTH | green << QUANTIZE_WORD_WIDTH | blue;
            colorHistGram[quantizedColor] ++;
        }
        
        free(rawData);
        // length就是hist数组长度，也就是颜色直方图的横坐标最大值

        NSInteger length = sizeof(colorHistGram)/sizeof(colorHistGram[0]); // 131072 / 4
        
        // 算出不同颜色的种类数量
        
        self.distinctColors = [[NSMutableArray alloc]init];
        for (NSInteger color = 0; color < length ;color++){
            if (colorHistGram[color] > 0){
                [self.distinctColors addObject: [NSNumber numberWithInteger:color]];
            }
        }
        
        // 1、这里还可以优化一下，如果有某个色值的像素点数量大于整张图片的一半，就可以直接返回这个颜色值了
        
        // 2、颜色数量少于16种，非常简单，直接取数量最大的颜色即可，
        if (self.distinctColors.count <= QN_THEHE_COLOR_MAX_COUNT){
            if (!self.colorArray) {
                self.colorArray = [NSMutableArray array];
            }
            
            for (NSInteger i = 0;i < self.distinctColors.count ; i++){
                NSInteger color = [_distinctColors[i] integerValue];
                NSInteger pixelCount = colorHistGram[color];
                
                NSInteger red = [QNColorTransformer quantizedRed:color];
                NSInteger green = [QNColorTransformer quantizedGreen:color];
                NSInteger blue = [QNColorTransformer quantizedBlue:color];
                
                red = [QNColorTransformer modifyWordWidthWithValue:red currentWidth:QUANTIZE_WORD_WIDTH targetWidth:8];
                green = [QNColorTransformer modifyWordWidthWithValue:green currentWidth:QUANTIZE_WORD_WIDTH targetWidth:8];
                blue = [QNColorTransformer modifyWordWidthWithValue:blue currentWidth:QUANTIZE_WORD_WIDTH targetWidth:8];
                
                UIColor *realColor =  [UIColor colorWithRed:(CGFloat)red / 255
                                                      green:(CGFloat)green / 255
                                                       blue:(CGFloat)blue / 255
                                                      alpha:1];
                
                NSInteger colorPercentOfWholeImage = (NSInteger)(pixelCount * 100 / self.pixelCount);
                QNColorItem *colorItem = [[QNColorItem alloc] initWithColor:realColor
                                                                    percent:colorPercentOfWholeImage
                                                                 pixelCount:pixelCount];
                colorItem.isPureColor = YES;
                
                [self.colorArray addObject:colorItem];
            }
        } else {
            // 如果颜色数量大于16，开始中位切分算法，对颜色值进行归类，把相近的颜色归为一类颜色。
            self.priorityQueue = [[QNColorBoxPriorityQueue alloc] init];
            
            QNColorBox *colorBox = [[QNColorBox alloc] initWithLowerIndex:0
                                                               upperIndex:self.distinctColors.count - 1
                                                               colorArray:_distinctColors
                                                                     hist:(int *)(&colorHistGram)];
            
            [self.priorityQueue addColorBox:colorBox];
            
            // 开始进行颜色中位分裂算法
            [self splitBoxes:self.priorityQueue];

            [self calculateAverageColors:self.priorityQueue];
        }
        
        [self _sortColorResultByPixelCount];
        UIColor *imageThemeColor = [[self.colorArray firstObject] color];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            colorBlock(imageThemeColor, self.colorArray);
        });
    });
}

- (void)_sortColorResultByPixelCount {
    self.colorArray = [[self.colorArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        QNColorItem *color1 = (QNColorItem *)obj1;
        QNColorItem *color2 = (QNColorItem *)obj2;
        
        if (color1.pixelCount > color2.pixelCount) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }] mutableCopy];
}

- (void)calculateAverageColors:(QNColorBoxPriorityQueue *)queue {
    if (!self.colorArray) {
        self.colorArray = [NSMutableArray array];
    }
    
    NSMutableArray *colorBoxArray = [queue getColorBoxArray];
    for (QNColorBox *box in colorBoxArray){
        [box calculateAverageColor];
        
        NSInteger colorPercentOfWholeImage = (NSInteger)([box pixelTotalCount] * 100 / self.pixelCount);
        QNColorItem *colorItem = [[QNColorItem alloc] initWithColor:[box getAverageColor]
                                                            percent:colorPercentOfWholeImage
                                                         pixelCount:[box pixelTotalCount]];
        colorItem.isPureColor = box.isPureColor;
        [self.colorArray addObject:colorItem];
    }
}

- (void)splitBoxes:(QNColorBoxPriorityQueue*)queue {
    while (queue.count < QN_THEHE_COLOR_MAX_COUNT) {
        QNColorBox *colorBox = [queue poll];
        if (colorBox != nil && [colorBox canSplit]) {
            [queue addColorBox:[colorBox splitBox]];
            // 这里一定要重新add,(poll的时候已经移除掉了)因为原先的box被削掉一部分，他在队列中的位置就得发生变化，每次add会重新计算位置
            [queue addColorBox:colorBox];
        } else {
            if (colorBox) {
                // 当box内部只有一个像素点的时候，[colorBox canSplit] 返回NO,要记得重新add进queue,否则就丢失了
                [queue addColorBox:colorBox];
            } else {
                // 找不到可以分裂的box了
                return;
            }
        }
    }
}

- (unsigned char *)rawPixelDataFromImage:(UIImage *)image {
    CGImageRef cgImage = [image CGImage];
    NSUInteger width = CGImageGetWidth(cgImage);
    NSUInteger height = CGImageGetHeight(cgImage);
    
    unsigned char *rawData = (unsigned char *)malloc(height * width * 4);
    
    if (!rawData)
        return NULL;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    /* https://www.jianshu.com/p/d0214b976683
    * kCGImageAlphaPremultipliedLast 透明度预乘，我让设计师给了一张纯红色但是透明度为0.5的图片，可以最终拿到红色不是255而是128，Premultiplied预乘的意思就是rbg三分量都已经乘以透明度了
    * last代表a通道放最后（RGBA），first代表a通道放开头（ARGB）
    * kCGBitmapByteOrder32Big 选择大端字节序，是顺序的，也就是按照RGBA 展示，相反选择kCGBitmapByteOrder32Little就是 ABGR
    */
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
    CGContextRelease(context);
    
    self.pixelCount = (NSInteger)width * (NSInteger)height;
    
    return rawData;
}

- (void)clearHistArray {
    NSInteger length = sizeof(colorHistGram)/sizeof(colorHistGram[0]);
    for (NSInteger i = 0; i < length; i++) {
        colorHistGram[i] = 0;
    }
}

@end
