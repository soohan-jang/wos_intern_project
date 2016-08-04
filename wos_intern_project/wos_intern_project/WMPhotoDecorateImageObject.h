//
//  WMPhotoDecorateImageObject.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "WMPhotoDecorateObject.h"

@interface WMPhotoDecorateImageObject : WMPhotoDecorateObject

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithImage:(UIImage *)image identifier:(NSString *)identifier;
- (instancetype)initWithImage:(UIImage *)image timestamp:(NSNumber *)timestamp;

@end
