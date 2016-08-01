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
        self.image = image;
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image WithTimestamp:(NSNumber *)timestamp {
    self = [super initWithTimestamp:timestamp];
    
    if (self) {
        self.image = image;
    }
    
    return self;
}

- (UIView *)getView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    return imageView;
}

- (void)containsPoint:(CGPoint)point {}
- (void)moveObject:(CGPoint)movePoint {}
- (void)resizeObject:(CGRect)resizeRect {}
- (void)rotateObject:(CGFloat)rotateAngle {}

@end
