//
//  PhotoDecorateData.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDecorateData : NSObject

@property (nonatomic, strong) NSNumber *timestamp;
@property (nonatomic, strong) id data;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGFloat angle;

/**
 Timestamp를 받아 z-order를 설정하고, 객체의 identifier를 만들어 설정한다.
 */
- (instancetype)initWithTimestamp:(NSNumber *)timestamp;

/**
 설정된 정보로 UIView를 생성하여 반환한다.
 */
- (UIView *)getView;

/**
 객체의 위치정보를 갱신한다.
 */
- (void)move:(CGPoint)movePoint;

/**
 객체의 크기정보를 갱신한다.
 */
- (void)resize:(CGRect)resizeRect;

/**
 객체의 회전정보를 갱신한다.
 */
- (void)rotate:(CGFloat)rotateAngle;


- (void)changeZOrder;

@end