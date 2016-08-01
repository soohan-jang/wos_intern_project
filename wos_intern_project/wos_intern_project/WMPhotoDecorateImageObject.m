//
//  WMPhotoDecorateImageObject.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "WMPhotoDecorateImageObject.h"

@interface WMPhotoDecorateImageObject ()

@end

@implementation WMPhotoDecorateImageObject

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    
    if (self) {
        self.image = image;
        self.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image WithID:(NSString *)identifier {
    self = [super init];
    
    if (self) {
        self.id_hashed_timestamp = [self createObjectId:identifier];
        self.image = image;
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image WithTimestamp:(NSNumber *)timestamp {
    self = [super initWithTimestamp:timestamp];
    
    if (self) {
        self.image = image;
        self.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    
    return self;
}

- (id)getData {
    return self.image;
}

- (UIView *)getView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.frame = self.frame;
    
    return imageView;
}

- (void)containsPoint:(CGPoint)point {}
- (void)moveObject:(CGPoint)movePoint {}
- (void)resizeObject:(CGRect)resizeRect {}
- (void)rotateObject:(CGFloat)rotateAngle {}

@end
