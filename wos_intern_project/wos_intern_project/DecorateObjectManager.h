//
//  DecorateObjectManager.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMPhotoDecorateObject.h"
#import "WMPhotoDecorateImageObject.h"
#import "WMPhotoDecorateTextObject.h"

@interface DecorateObjectManager : NSObject

- (void)addDecorateObject:(WMPhotoDecorateObject *)object;
- (void)removeDecorateObjectAtIndex:(NSInteger)index;
- (UIView *)getDecorateObjectAtIndex:(NSInteger)index;

- (void)sortDecorateObject;
- (BOOL)isEmpty;
- (NSInteger)getCount;

@end
