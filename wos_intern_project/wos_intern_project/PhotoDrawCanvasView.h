//
//  PhotoDrawCanvasView.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 8. 6..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, Mode) {
    ModeDraw    = 0,
    ModeErase   = 1
};

extern CGFloat const DefaultLineWidth;

@interface PhotoDrawCanvasView : UIView

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) NSInteger lineWidth;
@property (nonatomic, assign) NSInteger drawMode;

/**
 * @brief 그려진 Path 객체의 경계를 계산하여, 그려진 영역만큼을 캡쳐한다.
 * @return UIImage : 캡쳐된 이미지가 담긴 객체
 */
- (UIImage *)viewCapture;

/**
 * @brief 그려진 Path 객체를 모두 지운다.
 */
- (void)clear;

@end
