# YUNImageThemeColor
iOS端OC版本图片主题色识别框架

![image](https://github.com/yuzhiyunAtTencent/YUNImageThemeColor/blob/master/ReadmeImages/theme.jpeg)

<div align=center><img width="150" src="https://github.com/yuzhiyunAtTencent/YUNImageThemeColor/blob/master/ReadmeImages/theme.jpeg"/></div>

<div align=center><img width="150"  height="300" src="https://github.com/yuzhiyunAtTencent/YUNImageThemeColor/blob/master/ReadmeImages/theme.jpeg"/></div>
# 背景：
什么是图片主题色：
定义：一个代表具体图片整体颜色的近似值，简单来说，这个颜色值在图片内占用的面积最大。

比如下方左边图片识别出结果是绿色

![image](https://github.com/yuzhiyunAtTencent/YUNImageThemeColor/blob/master/ReadmeImages/1.png)

# 应用场景：
## 1、QQ音乐:
把音乐封面图主题色作为整体播放界面的背景色

![image](https://github.com/yuzhiyunAtTencent/YUNImageThemeColor/blob/master/ReadmeImages/2.png)

## 2、网易云音乐:
用户可以自己自定义个人页头部背景图，按钮颜色会相应的变化

![image](https://github.com/yuzhiyunAtTencent/YUNImageThemeColor/blob/master/ReadmeImages/3.png)

# 技术分析
## 1、最粗暴的想法：
当我们第一次面对这个需求的时候，在不参考任何资料的前提下，大家的初步想法都是一样简单粗暴的，就是首先从头到尾遍历图像的每一个像素点，获取每个像素点的颜色，然后统计每个颜色值出现的次数，次数最多那个颜色就是目标颜色了。



上图（我们称之为“颜色分布柱状图”）表达了这种最简单粗暴的想法，定义一个数组 int colorHistGram[2^24] 来记录整张图像的颜色值，index代表颜色值（范围： 黑色000000到白色FFFFFF），value代表这个颜色值在图像中出现的次数，那么上面柱状图最高的柱体对应的颜色就是目标值了。

## 2、肉眼与计算机的差异
上面这种想法为什么价值不大呢？

看个栗子：

我在下图中“蓝色天空”部分圈出了两个像素点，在计算机看来，point 1 的RBG具体数值和 point 2 存在细微的差异，而弱小的肉眼，是无法分辨这种细微差别的，人类大脑认为，1和2是一样的颜色。所以上面提到的简单粗暴的想法没什么意义，因为“一样”的颜色并没有使得“颜色分布柱状图”对应颜色的柱体变得更高，都被分散开来了。



## 3、解决颜色分散问题：聚合相近的颜色
那么问题来了，我们需要设计一种算法使得计算机模拟肉眼的行为，把相近的颜色聚合在一起，当成是一种颜色。



仍旧以上图为例子，我们希望实现的效果大概是：算法可以识别出有一大块蓝色（对应图中天空）、有一块绿色（对应图中树木）、有一小块白色（对应图中浪花）

首先给出两个颜色值差异的量化标准：

已知两个像素点颜色分别为：P1: (r1, g1, b1) P2: (r2, g2, b2)设两个像素点颜色的差距值为y，那么：

y^2 = (r2 - r1)^2 + (g2 - g1)^2 + (b2 - b1)^2

其实这就是空间距离的含义嘛。

正好我们在此引入颜色空间的概念，相信大家都很熟悉了，所有的颜色值都被涵盖在这个边长为255的正方体内部了，任何一个颜色值都对应空间内一个点。



现在来看看我们将要解析的图片，把一张图片每个像素点的颜色值对应到颜色空间内，大概是这样的（下图每个小球都对应一个像素点）：



那么我们的求图片主题色的目标已经转变为这样一个数学问题了，就是求出几个长方体，这几个长方体把相近的颜色包含在内部，然后我们要算出哪个长方体包含的像素点最多，那这个长方体对应的颜色就是图片主题色了。



## 4、中位切分算法（Medium-Cut algorithm）
最初，我们把图像对应的像素点对应到颜色空间后，得到了一个边长为255的立方体，现在我们要开始切割这个立方体。

(以下称这些长方体为box)

1、分别计算出当前box内 RBG 三个分量的最大值、最小值的差, 假设叫Δr 、Δg 、Δb，

D = max(Δr, Δg, Δb)， 找到最大的差值后，寻找一个垂直于该分量坐标轴的平面去切分box,

(比方说最大差值的颜色分量是 G, 用一个垂直于G轴的平面切分当前box)

使得切分后，当前box分裂为2个小的box,每个box包含的像素点数量一样,也就是各自一半

2、切完后，对所有的box以体积为维度做排序，取出体积最大的box

3、针对这个最大的box, 再次按照步骤1切割

4、重复1 2 3步骤直到 box个数达到阈值（比如16）

5、对每个box求颜色平均值，包含像素点数量最多的box的平均色值就是图片的主题色

步骤1示意图如下：



### 具体实现细节
#### 1、获取每个像素点的颜色值
在web端、Android端等不同平台API不一致，但是含义一样的，我的示例是iOS端的Objective C版本，以下函数传入一张图片，可以返回一个指针，该指针指向一块连续内存，每4个字节存储一个像素点的颜色值（RGBA分别占用一个字节）。

这样就拿到所有像素点的颜色了，然后就可以计算出最开头我们给出的“颜色分布柱状图”数组，index是颜色值、value是该颜色值对应像素点的数量

 int colorHistGram[2^24];

```
/// 返回一块存储图像像素点颜色信息的内存地址
/// @param image image description
- (unsigned char *)p_rawPixelDataFromImage:(UIImage *)image {
    if (!image) {
        return NULL;
    }
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

    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
    CGContextRelease(context);
    
    return rawData;
}
```

#### 2、“颜色分布柱状图”数组内存优化
回到最初提到的数组 int colorHistGram[2^24] 

优化前数组内存占用size = 2^24 * 4 bytes = 2^14 * 4 kb = 2 ^ 4 *4 mb = 64mb

这在客户端内是不太能接受的，所以我们把每个颜色值分量从8位改成5位，只取高5位，放弃低3位，这样颜色信息的损失非常小（本身肉眼也看不出。。。），却可以极大的减少数组的内存占用，于是数组变成了 int colorHistGram[2^15]

优化后数组内存占用size = 2^15 * 4 bytes = 2^5 * 4 kb = 128 kb

#### 3、中位切分算法分割点寻找
得到 colorHistGram[2^15] 数组后，这个数组肯定存在很多个value为0的元素嘛，我们再用一个数组 distinctColors[n] 来存储所有非0的颜色信息，过滤掉不存在图像中的颜色值。与colorHistGram不同的是 distinctColors 数组元素的value直接代表颜色值。

因为切割过程中会产生多个box,需要记录每一个box都有哪些颜色值等，我们定义一个box类来记录这些信息：
```
// 对于最初的一个box对象， lowerIndex = 0，upperIndex = n - 1
@interface QNColorBox ( )

@property(nonatomic, assign) NSInteger lowerIndex; // 在数组distinctColors中的起始index
@property(nonatomic, assign) NSInteger upperIndex; // 在数组distinctColors中的结束index

@end
然后我们针对目标box开始寻找分割点

// 寻找当前box内跨度最大的颜色分量
NSInteger longestDimension = [self getLongestColorDimension];
    
// 修改颜色，改成以某一个维度为排序标准的新颜色值
[self modifySignificantOctetWithDismension:longestDimension lowerIndex:_lowerIndex upperIndex:_upperIndex];
    
// 把颜色按照新的维度进行排序
[self sortColorArray];
    
// 排序后恢复成原来的颜色值，不能破坏颜色值
[self modifySignificantOctetWithDismension:longestDimension lowerIndex:_lowerIndex upperIndex:_upperIndex];
```


如上代码，比如说：

1、分隔面是垂直于G轴的（就是说跨度最大颜色分量是G），

2、原来的颜色都是按照R>G>B的顺序排列的，为了排序，首先把box内每个颜色值的G和R(一直都是R)交换位置，得到新的颜色值

3、然后我们对box内所有颜色值排序，排序后，distinctColors数组内部的元素位置就发生交换了，从lowerIndex到upperIndex范围的颜色值是按照G分量来做排序的

4、排序后，我们还得还原颜色值为RBG顺序，不能破坏颜色值。

最后，我们开始从lowerIndex遍历distinctColors数组，计算目标分割点splitIndex是谁，可以使得lowerIndex~splitIndex和

splitIndex~upperIndex范围内的像素点数量是各自一半。

不断分隔后、直到box数量达到阈值比如16（google推荐的参数值）后，求出包含像素点数量最多的box即可。

## 参考
这个功能实现最初是google提出的，并且集成在Android support包中，叫Palette框架

这是官方介绍 ：https://developer.android.com/training/material/palette-colors#java

框架的代码也是开源的，只有三个文件：

https://www.androidos.net.cn/android/8.0.0_r4/xref/frameworks/support/v7/palette/src/main/java/android/support/v7/graphics



也参考了一个iOS 端的项目 ： https://github.com/tangdiforx/iOSPalette


引入#import "UIImage+ThemeColor.h"

然后调用函数即可 - (void)getThemeColor:(QNGetColorBlock)colorBlock