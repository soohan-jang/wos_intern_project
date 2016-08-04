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

- (void)addDecorateObject:(WMPhotoDecorateObject *)decoObject {
    if (self.decorateObjectArray == nil) {
        self.decorateObjectArray = [@[decoObject] mutableCopy];
    } else {
        [self.decorateObjectArray addObject:decoObject];
    }
}

- (void)updateDecorateObjectWithId:(NSString *)identifier WithOriginX:(CGFloat)originX WithOriginY:(CGFloat)originY {
    if (![self isEmpty]) {
        for (WMPhotoDecorateObject *decoObject in self.decorateObjectArray) {
            if ([[decoObject getID] isEqualToString:identifier]) {
                [decoObject moveObject:CGPointMake(originX, originY)];
                break;
            }
        }
    }
}

- (void)updateDecorateObjectWithId:(NSString *)identifier WithWidth:(CGFloat)width WithHeight:(CGFloat)height {
    if (![self isEmpty]) {
        for (WMPhotoDecorateObject *decoObject in self.decorateObjectArray) {
            if ([[decoObject getID] isEqualToString:identifier]) {
                [decoObject resizeObject:CGSizeMake(width, height)];
                break;
            }
        }
    }
}

- (void)updateDecorateObjectWithId:(NSString *)identifier WithAngle:(CGFloat)angle {
    if (![self isEmpty]) {
        for (WMPhotoDecorateObject *decoObject in self.decorateObjectArray) {
            if ([[decoObject getID] isEqualToString:identifier]) {
                [decoObject rotateObject:angle];
                break;
            }
        }
    }
}

- (void)updateDecorateObjectZOrderWithId:(NSString *)identifier {
    if (![self isEmpty]) {
        for (WMPhotoDecorateObject *decoObject in self.decorateObjectArray) {
            if ([[decoObject getID] isEqualToString:identifier]) {
                
                break;
            }
        }
    }
}

- (void)deleteDecorateObjectWithId:(NSString *)identifier {
    if (![self isEmpty]) {
        for (WMPhotoDecorateObject *decoObject in self.decorateObjectArray) {
            if ([[decoObject getID] isEqualToString:identifier]) {
                [self.decorateObjectArray removeObject:decoObject];
                break;
            }
        }
    }
}

- (WMPhotoDecorateObject *)getDecorateObjectWithId:(NSString *)identifier {
    if (![self isEmpty]) {
        for (WMPhotoDecorateObject *decoObject in self.decorateObjectArray) {
            if ([[decoObject getID] isEqualToString:identifier]) {
                return decoObject;
            }
        }
    }
    
    return nil;
}

//내부에 존재하는 deco object를 view로 변환하여 전달한다.
- (NSArray *)getDecorateViewArray {
    if (![self isEmpty]) {
        NSMutableArray *viewArray = [[NSMutableArray alloc] initWithCapacity:self.decorateObjectArray.count];
        for (WMPhotoDecorateObject *decoObject in self.decorateObjectArray) {
            UIView *view = [decoObject getView];
            [view setStringTag:[decoObject getID]];
            [viewArray addObject:view];
        }
        
        return viewArray;
    }
    
    return nil;
}

- (void)sortDecorateObjects {
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
    if ([self isEmpty]) {
        return 0;
    } else {
        return self.decorateObjectArray.count;
    }
}

@end