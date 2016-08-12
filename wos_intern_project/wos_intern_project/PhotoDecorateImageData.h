//
//  PhotoDecorateImageData.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoDecorateData.h"

@interface PhotoDecorateImageData : PhotoDecorateData

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithImage:(UIImage *)image widthRadio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio timestamp:(NSNumber *)timestamp;

@end
