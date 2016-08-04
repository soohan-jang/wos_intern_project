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
        self.data = image;
        self.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image identifier:(NSString *)identifier {
    self = [super init];
    
    if (self) {
        self.id_hashed_timestamp = [self createObjectId:identifier];
        self.data = image;
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image timestamp:(NSNumber *)timestamp {
    self = [super initWithTimestamp:timestamp];
    
    if (self) {
        self.data = image;
        self.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    
    return self;
}

- (UIView *)getView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.data];
    imageView.frame = self.frame;
    
    return imageView;
}

@end
