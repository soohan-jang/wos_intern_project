//
//  PhotoDrawObjectDisplayView.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIView+StringTag.h"
#import "WMPhotoDecorateObject.h"

extern NSInteger const DECO_VIEW_Z_ORDER_UP;
extern NSInteger const DECO_VIEW_Z_ORDER_DOWN;

@protocol PhotoDrawObjectDisplayViewDelegate;

@interface PhotoDrawObjectDisplayView : UIView

@property (nonatomic, weak) id<PhotoDrawObjectDisplayViewDelegate> delegate;

- (void)addDecoView:(UIView *)decoView;
- (void)updateDecoViewWithId:(NSString *)identifier WithOriginX:(CGFloat)originX WithOriginY:(CGFloat)originY;
- (void)updateDecoViewWithId:(NSString *)identifier WithWidth:(CGFloat)width WithHeight:(CGFloat)height;
- (void)updateDecoViewWithId:(NSString *)identifier WithAngle:(CGFloat)angle;
- (void)updateDecoViewWithId:(NSString *)identifier WithZOrder:(NSInteger)changeZOrder;
- (void)deleteDecoViewWithId:(NSString *)identifier;

- (void)drawDecoViews:(NSArray *)decoViews;
- (void)setEnableWithId:(NSString *)indentifier WithEnable:(BOOL)enable;

@end

@protocol PhotoDrawObjectDisplayViewDelegate <NSObject>

@required
- (void)decoViewDidMovedWithId:(NSString *)identifier WithOriginX:(CGFloat)originX WithOriginY:(CGFloat)originY;
- (void)decoViewDidResizedWithId:(NSString *)identifier WithResizedWidth:(CGFloat)width WithResizedHeight:(CGFloat)height;
- (void)decoViewDidRotatedWithId:(NSString *)identifier WithRotatedAngle:(CGFloat)angle;
- (void)decoViewDidDeletedWithId:(NSString *)identifier;

@end