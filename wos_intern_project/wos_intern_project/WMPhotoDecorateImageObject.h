//
//  WMPhotoDecorateImageObject.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "WMPhotoDecorateObject.h"
#import <UIKit/UIImage.h>
#import <UIKit/UIImageView.h>
#import <UIKit/UITapGestureRecognizer.h>
#import <UIKit/UIPanGestureRecognizer.h>

@interface WMPhotoDecorateImageObject : WMPhotoDecorateObject

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithImage:(UIImage *)image WithID:(NSString *)identifier;
- (instancetype)initWithImage:(UIImage *)image WithTimestamp:(NSNumber *)timestamp;

@end
