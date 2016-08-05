//
//  WMPhotoDecorateObject.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMPhotoDecorateObject : NSObject

@property (nonatomic, copy, setter=setID:, getter=getID) NSString * id_hashed_timestamp;
@property (nonatomic, strong, setter=setZOrder:, getter=getZOrder) NSNumber *z_order_timestamp;
@property (nonatomic, strong, setter=setData:, getter=getData) id data;
@property (nonatomic, assign, setter=setFrame:, getter=getFrame) CGRect frame;
@property (nonatomic, assign, setter=setAngle:, getter=getAngle) CGFloat angle;

/**
 Timestamp를 받아 z-order를 설정하고, 객체의 identifier를 만들어 설정한다.
 */
- (instancetype)initWithTimestamp:(NSNumber *)timestamp;
/**
 input을 받아 SHA-1으로 Hash한 뒤, 결과값을 반환한다.
 */
- (NSString *)createObjectId:(NSString *)input;

/**
 설정된 정보로 UIView를 생성하여 반환한다.
 */
- (UIView *)getView;
/**
 객체의 위치정보를 갱신한다.
 */
- (void)moveObject:(CGPoint)movePoint;
/**
 객체의 크기정보를 갱신한다.
 */
- (void)resizeObject:(CGRect)resizeRect;
/**
 객체의 회전정보를 갱신한다.
 */
- (void)rotateObject:(CGFloat)rotateAngle;

@end