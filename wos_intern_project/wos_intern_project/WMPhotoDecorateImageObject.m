//
//  WMPhotoDecorateImageObject.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "WMPhotoDecorateImageObject.h"

@interface WMPhotoDecorateImageObject ()

@property (nonatomic, strong) UIImage *image;

@end

@implementation WMPhotoDecorateImageObject

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    
    if (self) {
        self.type = TYPE_IMAGE;
        self.image = image;
    }
    
    return self;
}

- (UIView *)getView {
    return [[UIImageView alloc] initWithImage:self.image];
}

- (void)containsPoint:(CGPoint)point {}
- (void)moveObject:(CGPoint)movePoint {}
- (void)resizeObject:(CGRect)resizeRect {}
- (void)rotateObject:(CGFloat)rotateAngle {}

@end
