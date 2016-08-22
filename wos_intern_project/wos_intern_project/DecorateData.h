//
//  DecorateData.ㅗ
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecorateView.h"

@interface DecorateData : NSObject

@property (nonatomic, strong, readonly) NSUUID *uuid;
@property (nonatomic, strong, readonly) NSNumber *timestamp;
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL enabled;

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithImage:(UIImage *)image scale:(CGFloat)scale;

- (DecorateView *)decorateView;

@end