//
//  PhotoDecorateData.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 30..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoDecorateData.h"

@interface PhotoDecorateData ()

@end

@implementation PhotoDecorateData

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    
    if (self) {
         self.timestamp = @([[NSDate date] timeIntervalSince1970] * 1000);
        self.data = image;
        self.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image widthRadio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio timestamp:(NSNumber *)timestamp {
    self = [super init];
    
    if (self) {
        self.data = image;
        self.frame = CGRectMake(0, 0, image.size.width / widthRatio, image.size.height / heightRatio);
        self.timestamp = timestamp;
    }
    
    return self;
}

- (UIImageView *)getView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.data];
    imageView.frame = self.frame;
    
    return imageView;
}

- (void)move:(CGPoint)movePoint {
    _frame = CGRectMake(movePoint.x, movePoint.y, _frame.size.width, _frame.size.height);
}

- (void)resize:(CGRect)resizeRect {
    _frame = resizeRect;
}

- (void)rotate:(CGFloat)rotateAngle {
    _angle = rotateAngle;
}

- (void)changeZOrder {

}

@end
