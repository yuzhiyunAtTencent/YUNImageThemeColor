//
//  QNColorBoxPriorityQueue.m
//  Helloworld
//
//  Created by zhiyunyu on 2020/3/5.
//  Copyright © 2020 zhiyunyu. All rights reserved.
//

#import "QNColorBoxPriorityQueue.h"

@interface QNColorBoxPriorityQueue ()

@property (nonatomic,strong) NSMutableArray *colorBoxArray;

@end

@implementation QNColorBoxPriorityQueue

- (instancetype)init{
    self = [super init];
    if (self){
        self.colorBoxArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)addColorBox:(QNColorBox *)box {
    
    if (![box isKindOfClass:[QNColorBox class]]){
        return;
    }
    if ([self.colorBoxArray count] <= 0){
        [self.colorBoxArray addObject:box];
        return;
    }
    
    for (int i = 0 ; i < [self.colorBoxArray count] ; i++){
        QNColorBox *nowBox = (QNColorBox*)[self.colorBoxArray objectAtIndex:i];
        
        if ([box getVolume] > [nowBox getVolume]){
            [self.colorBoxArray insertObject:box atIndex:i];
            if (self.colorBoxArray.count > QN_THEHE_COLOR_MAX_COUNT){
                [self.colorBoxArray removeObjectAtIndex:QN_THEHE_COLOR_MAX_COUNT];
            }
            return;
        }
        
        if ((i == [self.colorBoxArray count] - 1) && self.colorBoxArray.count < QN_THEHE_COLOR_MAX_COUNT){
            [self.colorBoxArray addObject:box];
            
            return;
        }
    }
}

- (id)objectAtIndex:(NSInteger)i{
    return [self.colorBoxArray objectAtIndex:i];
}

- (id)poll{
    if (self.colorBoxArray.count <= 0){
        return nil;
    }
    
    for (int i = 0; i < self.colorBoxArray.count; i++) {
        QNColorBox *box = [self.colorBoxArray objectAtIndex:i];
        if (box.shouldParticipateInVolumeSort) {
            [self.colorBoxArray removeObject:box];
            return box;
        }
    }
    return nil;
}

- (NSUInteger)count {
    return self.colorBoxArray.count;
}

- (NSMutableArray*)getColorBoxArray {
    return self.colorBoxArray;
}

@end
