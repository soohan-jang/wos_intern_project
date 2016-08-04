//
//  WMPhotoDecorateTextObject.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "WMPhotoDecorateObject.h"

@interface WMPhotoDecorateTextObject : WMPhotoDecorateObject

- (instancetype)initWithText:(NSString *)text;
- (instancetype)initWithText:(NSString *)text identifier:(NSString *)identifier;
- (instancetype)initWithText:(NSString *)text timestamp:(NSNumber *)timestamp;

@end
