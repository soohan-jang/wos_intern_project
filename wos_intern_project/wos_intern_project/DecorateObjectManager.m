//
//  DecorateObjectManager.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "DecorateObjectManager.h"

@interface DecorateObjectManager ()

@property (nonatomic, strong) NSMutableArray *decorateObjectArray;

@end

@implementation DecorateObjectManager

- (void)addDecorateObject:(WMPhotoDecorateObject *)object {
    if (self.decorateObjectArray == nil) {
        self.decorateObjectArray = [@[object] mutableCopy];
    } else {
        [self.decorateObjectArray addObject:object];
    }
}

- (void)removeDecorateObjectAtIndex:(NSInteger)index {
    if (![self isEmpty]) {
        [self.decorateObjectArray removeObjectAtIndex:index];
    }
}

- (UIView *)getDecorateObjectAtIndex:(NSInteger)index {
    if (![self isEmpty]) {
        return self.decorateObjectArray[index];
    }
    
    return nil;
}
//- (void)drawOnCanvasView:(UIView *)canvasView {
//    if (canvasView == nil) {
//        return;
//    }
//    
//    if (canvasView.subviews.count > 0) {
//        for (UIView *subView in canvasView.subviews) {
//            for (UIGestureRecognizer *recognizer in subView.gestureRecognizers) {
//                [subView removeGestureRecognizer:recognizer];
//            }
//            [subView removeFromSuperview];
//        }
//    }
//    
//    if (![self isEmpty]) {
//        for (WMPhotoDecorateObject *decoObject in self.decorateViewArray) {
//            [canvasView addSubview:[decoObject getView]];
//        }
//    }
//}

- (void)sortDecorateObject {
    if (![self isEmpty]) {
        [self.decorateObjectArray sortUsingComparator:^NSComparisonResult(WMPhotoDecorateObject  *_Nonnull obj1, WMPhotoDecorateObject  *_Nonnull obj2) {
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
    if (self.decorateObjectArray != nil && self.decorateObjectArray.count > 0) {
        return NO;
    }
    
    return YES;
}

- (NSInteger)getCount {
    return self.decorateObjectArray.count;
}

@end
