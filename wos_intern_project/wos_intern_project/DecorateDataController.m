//
//  DecorateDataController.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "DecorateDataController.h"

@interface DecorateDataController ()

@property (nonatomic, strong) NSMutableArray<PhotoDecorateData *> *decorateDataArray;

@end

@implementation DecorateDataController

- (void)addDecorateData:(PhotoDecorateData *)decoData {
    if (self.decorateDataArray == nil) {
        self.decorateDataArray = [@[decoData] mutableCopy];
    } else {
        [self.decorateDataArray addObject:decoData];
    }
}

- (void)updateDecorateDataAtIndex:(NSInteger)index point:(CGPoint)point {
    if ([self isOutBoundIndex:index])
        return;
    
    [self.decorateDataArray[index] move:point];
}

- (void)updateDecorateDataAtIndex:(NSInteger)index rect:(CGRect)rect {
    if ([self isOutBoundIndex:index])
        return;
    
    [self.decorateDataArray[index] resize:rect];
}

- (void)updateDecorateDataAtIndex:(NSInteger)index angle:(CGFloat)angle {
    if ([self isOutBoundIndex:index])
        return;
    
    [self.decorateDataArray[index] rotate:angle];
}

- (void)updateDecorateDataZOrderAtIndex:(NSInteger)index {
    if ([self isOutBoundIndex:index])
        return;
    
    [self.decorateDataArray[index] changeZOrder];
}

- (void)deleteDecorateDataAtIndex:(NSInteger)index {
    if ([self isOutBoundIndex:index])
        return;
    
    [self.decorateDataArray removeObjectAtIndex:index];
}

- (PhotoDecorateData *)getDecorateDataAtIndex:(NSInteger)index {
    if ([self isOutBoundIndex:index])
        return nil;
    
    return self.decorateDataArray[index];
}

//내부에 존재하는 deco Data를 view로 변환하여 전달한다.
- (NSArray *)getDecorateViewArray {
    if (![self isEmpty]) {
        NSMutableArray<UIView *> *viewArray = [[NSMutableArray alloc] initWithCapacity:self.decorateDataArray.count];
        for (PhotoDecorateData *decoData in self.decorateDataArray) {
            UIView *view = [decoData getView];
            [viewArray addObject:view];
        }
        
        return viewArray;
    }
    
    return nil;
}

- (void)sortDecorateDatas {
    if (![self isEmpty]) {
//        [self.decorateDataArray sortUsingComparator:^NSComparisonResult(PhotoDecorateData  *_Nonnull obj1, PhotoDecorateData  *_Nonnull obj2) {
//            //뭐가 오름차순인지 모르겠네? 일단 구현해놓고 나중에 수정하자.
//            if ([obj1 getZOrder] < [obj2 getZOrder]) {
//                return YES;
//            } else {
//                return NO;
//            }
//        }];
    }
}

- (BOOL)isEmpty {
    if (self.decorateDataArray != nil && self.decorateDataArray.count > 0) {
        return NO;
    }
    
    return YES;
}

- (NSInteger)getCount {
    if ([self isEmpty]) {
        return 0;
    } else {
        return self.decorateDataArray.count;
    }
}

- (BOOL)isOutBoundIndex:(NSInteger)index {
    if (index < [self getCount])
        return NO;
    
    return YES;
}

@end
