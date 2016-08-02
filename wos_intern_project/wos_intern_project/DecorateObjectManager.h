//
//  DecorateObjectManager.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+StringTag.h"
#import "WMPhotoDecorateObject.h"
#import "WMPhotoDecorateImageObject.h"
#import "WMPhotoDecorateTextObject.h"

@interface DecorateObjectManager : NSObject

- (void)addDecorateObject:(WMPhotoDecorateObject *)object;
- (void)updateDecorateObjectWithId:(NSString *)identifier WithOriginX:(CGFloat)originX WithOriginY:(CGFloat)originY;
- (void)updateDecorateObjectWithId:(NSString *)identifier WithWidth:(CGFloat)width WithHeight:(CGFloat)height;
- (void)updateDecorateObjectWithId:(NSString *)identifier WithAngle:(CGFloat)angle;
- (void)updateDecorateObjectZOrderWithId:(NSString *)identifier;
- (void)deleteDecorateObjectWithId:(NSString *)identifier;
- (WMPhotoDecorateObject *)getDecorateObjectWithId:(NSString *)identifier;

- (NSArray *)getDecorateViewArray;

- (void)sortDecorateObject;
- (BOOL)isEmpty;
- (NSInteger)getCount;

@end
