//
//  DecorateDataController.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "DecorateDataController.h"

@interface DecorateDataController ()

@property (atomic, strong) NSMutableArray<PhotoDecorateData *> *decorateDataArray;

@end

@implementation DecorateDataController

- (void)addDecorateData:(PhotoDecorateData *)decoData {
    if (!decoData) {
        return;
    }
    
    if (self.decorateDataArray == nil) {
        self.decorateDataArray = [@[decoData] mutableCopy];
    } else {
        [self.decorateDataArray addObject:decoData];
        [self sortDecorateDatas];
    }
}

- (void)updateDecorateDataAtIndex:(NSInteger)index point:(CGPoint)point {
    if ([self isOutBoundIndex:index]) {
        return;
    }
    
    [self.decorateDataArray[index] move:point];
}

- (void)updateDecorateDataAtIndex:(NSInteger)index rect:(CGRect)rect {
    if ([self isOutBoundIndex:index]) {
        return;
    }
    
    [self.decorateDataArray[index] resize:rect];
}

- (void)updateDecorateDataAtIndex:(NSInteger)index angle:(CGFloat)angle {
    if ([self isOutBoundIndex:index]) {
        return;
    }
    
    [self.decorateDataArray[index] rotate:angle];
}

- (void)updateDecorateDataZOrderAtIndex:(NSInteger)index {
    if ([self isOutBoundIndex:index]) {
        return;
    }
    
    [self.decorateDataArray[index] changeZOrder];
}

- (void)deleteDecorateDataAtIndex:(NSInteger)index {
    if ([self isOutBoundIndex:index]) {
        return;
    }
    
    [self.decorateDataArray removeObjectAtIndex:index];
}

- (NSUInteger)getIndexOfTimestamp:(NSNumber *)timestamp {
    if (!timestamp || [self isEmpty]) {
        return NSNotFound;
    }
    
    NSInteger index = 0;
    for (PhotoDecorateData *decoData in self.decorateDataArray) {
        if ([decoData.timestamp isEqualToNumber:timestamp]) {
            return index;
        }
        index++;
    }
    
    return NSNotFound;
}

- (NSUInteger)getIndexOfDecorateData:(PhotoDecorateData *)data {
    if (!data || [self isEmpty]) {
        return NSNotFound;
    }
    
    return [self.decorateDataArray indexOfObject:data];
}

- (PhotoDecorateData *)getDecorateDataAtIndex:(NSInteger)index {
    if ([self isOutBoundIndex:index]) {
        return nil;
    }
    
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

//동기식 정렬을 수행한다. 따라서 이 메소드를 호출한 뒤에 작업을 진행한다고 비동기성으로 문제가 발생하지 않는다.
- (void)sortDecorateDatas {
    if (![self isEmpty]) {
        [self.decorateDataArray sortUsingComparator:^NSComparisonResult(PhotoDecorateData  *_Nonnull obj1, PhotoDecorateData  *_Nonnull obj2) {
            return [obj1.timestamp compare:obj2.timestamp];
        }];
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
    if ([self isEmpty]) {
        return YES;
    }
    
    if (index < [self getCount]) {
        return NO;
    }
    
    return YES;
}

@end
