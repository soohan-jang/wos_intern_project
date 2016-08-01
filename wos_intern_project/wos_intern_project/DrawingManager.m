//
//  DrawingManager.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "DrawingManager.h"

@interface DrawingManager ()

@property (nonatomic, strong) NSMutableArray *decorateViewArray;

@end

@implementation DrawingManager

- (void)addDecorateObject:(WMPhotoDecorateObject *)object {
    if (self.decorateViewArray == nil) {
        self.decorateViewArray = [@[object] mutableCopy];
    } else {
        [self.decorateViewArray addObject:object];
    }
}

- (void)removeDecorateObjectAtIndex:(NSInteger)index {
    if (![self isEmpty]) {
        [self.decorateViewArray removeObjectAtIndex:index];
    }
}

- (UIView *)getDecorateObjectAtIndex:(NSInteger)index {
    if (![self isEmpty]) {
        return self.decorateViewArray[index];
    }
    
    return nil;
}

- (void)drawOnCanvasView:(UIView *)canvasView {
    if (canvasView == nil) {
        return;
    }
    
    if (canvasView.subviews.count > 0) {
        for (UIView *subView in canvasView.subviews) {
            [subView removeFromSuperview];
        }
    }
    
    if (![self isEmpty]) {
        for (WMPhotoDecorateObject *decoObject in self.decorateViewArray) {
            [canvasView addSubview:[decoObject getView]];
        }
    }
}

- (void)sortDecorateObject {
    if (![self isEmpty]) {
        [self.decorateViewArray sortUsingComparator:^NSComparisonResult(WMPhotoDecorateObject  *_Nonnull obj1, WMPhotoDecorateObject  *_Nonnull obj2) {
            //뭐가 오름차순인지 모르겠네? 일단 구현해놓고 나중에 수정하자.
            if ([obj1 getZOrder] < [obj2 getZOrder]) {
                return YES;
            } else {
                return NO;
            }
        }];
    }
}

- (BOOL)isEmpty {
    if (self.decorateViewArray != nil && self.decorateViewArray.count > 0) {
        return NO;
    }
    
    return YES;
}

@end
