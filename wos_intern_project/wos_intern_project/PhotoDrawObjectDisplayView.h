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

@property (weak, nonatomic) id<PhotoDrawObjectDisplayViewDelegate> delegate;

/**
 그려진 객체를 추가한다. 추가된 객체는 DisplayView에 addSubView되어 화면에 표시된다. GestureRecognizer도 함께 추가한다.
 */
- (void)addDecoView:(UIView *)decoView;
/**
 그려진 객체의 위치를 변경한다. 위치 변경은 frame.origin.x와 frame.origin.y의 값을 파라메터의 값으로 설정하여 변경한다.
 */
- (void)updateDecoViewWithId:(NSString *)identifier WithOriginX:(CGFloat)originX WithOriginY:(CGFloat)originY;
/**
 그려진 객체의 크기를 변경한다. 위치 변경은 frame.size.width와 frame.size.height의 값을 파라메터의 값으로 설정하여 변경한다.
 */
- (void)updateDecoViewWithId:(NSString *)identifier WithWidth:(CGFloat)width WithHeight:(CGFloat)height;
/**
 그려진 객체를 회전시킨다. 회전 각도는 파라메터의 angle 값으로 설정한다. AffineTransform를 사용해야 할 것 같은데, 아직 미구현 상태이다.
 이 메소드는 상황에 따라 구현이 늦어질 수 있다.
 */
- (void)updateDecoViewWithId:(NSString *)identifier WithAngle:(CGFloat)angle;
/**
 그려진 객체 중 identifier에 해당하는 객체를 가장 위로 올린다. bringToFront를 사용한다
 */
- (void)updateDecoViewZOrderWithId:(NSString *)identifier;
/**
 그려진 객체 중 identifier에 해당하는 객체를 삭제한다. removeSuperview를 사용하며, GestureRecognizer도 함께 제거한다.
 */
- (void)deleteDecoViewWithId:(NSString *)identifier;

/**
 그려진 객체의 배열을 받아 다수의 객체를 추가하고, DisplayView에 addSubView한다. GestureRecognizer도 함께 추가한다.
 */
- (void)drawDecoViews:(NSArray *)decoViews;
/**
 그려진 객체 중 identifier에 해당하는 객체의 편집가능 여부를 설정한다. 편집가능 여부는 enable로 설정한다.
 enable = NO로 설정된 객체는 그 위에 반투명한 편집불가능 알림 ImageView가 표시된다.
 */
- (void)setEnableWithId:(NSString *)indentifier WithEnable:(BOOL)enable;

@end

/**
 PhotoDrawObjectDisplayView에서 발생하는 일을 처리하기 위한 Delegate이다.
 DisplayView 위에 표시된 객체들이 이동/크기변경/회전/Z-order 변경/삭제되었을 때의 상황을 Delegate로 전파한다.
 */
@protocol PhotoDrawObjectDisplayViewDelegate <NSObject>
@required
/**
 객체가 이동했을 때 identifier, 이동한 위치를 전달한다.
 */
- (void)decoViewDidMovedWithId:(NSString *)identifier WithOriginX:(CGFloat)originX WithOriginY:(CGFloat)originY;
/**
 객체의 크기가 변경되었을 때 identifier, 변경된 높이와 너비를 전달한다.
 */
- (void)decoViewDidResizedWithId:(NSString *)identifier WithResizedWidth:(CGFloat)width WithResizedHeight:(CGFloat)height;
/**
 객체가 회전되었을 때 identifier, 회전한 각도를 전달한다.
 */
- (void)decoViewDidRotatedWithId:(NSString *)identifier WithRotatedAngle:(CGFloat)angle;
/**
 객체의 Z-order가 변경되었을 때 identifier를 전달한다.
 */
- (void)decoViewDidChangedZOrderWithId:(NSString *)identifier;
/**
 객체가 삭제되었을 때 identifier를 전달한다.
 */
- (void)decoViewDidDeletedWithId:(NSString *)identifier;

@end