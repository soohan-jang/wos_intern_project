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

extern const NSInteger TYPE_NONE;
extern const NSInteger TYPE_TEXT;
extern const NSInteger TYPE_IMAGE;

@interface WMPhotoDecorateObject : NSObject

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy, setter=setID:, getter=getID) NSString * id_hashed_timestamp;
@property (nonatomic, strong, setter=setZOrder:, getter=getZOrder) NSNumber *z_order_timestamp;

- (UIView *)getView;
- (void)containsPoint:(CGPoint)point;
- (void)moveObject:(CGPoint)movePoint;
- (void)resizeObject:(CGRect)resizeRect;
- (void)rotateObject:(CGFloat)rotateAngle;

@end