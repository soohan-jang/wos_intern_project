//
//  WMPhotoDecorateObject.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>
#import <CoreGraphics/CoreGraphics.h>

@interface WMPhotoDecorateObject : NSObject

@property (nonatomic, copy, setter=setID:, getter=getID) NSString * id_hashed_timestamp;
@property (nonatomic, strong, setter=setZOrder:, getter=getZOrder) NSNumber *z_order_timestamp;
@property (nonatomic, assign) CGRect frame;

- (instancetype)initWithTimestamp:(NSNumber *)timestamp;

- (UIView *)getView;
- (void)containsPoint:(CGPoint)point;
- (void)moveObject:(CGPoint)movePoint;
- (void)resizeObject:(CGRect)resizeRect;
- (void)rotateObject:(CGFloat)rotateAngle;

@end