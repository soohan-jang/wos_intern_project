//
//  DecorateDataDisplayView.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DecorateView.h"

@protocol DecorateDisplayViewDelegate;
@protocol DecorateDisplayViewDataSource;

@interface DecorateDisplayView : UIView

@property (weak, nonatomic) id<DecorateDisplayViewDelegate> delegate;
@property (weak, nonatomic) id<DecorateDisplayViewDataSource> dataSource;

//Logic.
- (void)updateDecorateViewOfUUID:(NSUUID *)uuid;

//Draw Control Buttons - Resize / Delete
- (void)drawControlButtonsOnSelectedDecorateView;
- (void)removeControlButtonsFromSelectedDecorateView;

//Get view from self.subviews
- (DecorateView *)decorateViewOfUUID:(NSUUID *)uuid;

//View screen capture
- (UIImage *)viewCapture;

@end

/**
 PhotoDrawObjectDisplayView에서 발생하는 일을 처리하기 위한 Delegate이다.
 DisplayView 위에 표시된 객체들이 이동/크기변경/회전/Z-order 변경/삭제되었을 때의 상황을 Delegate로 전파한다.
 */
@protocol DecorateDisplayViewDelegate <NSObject>
@required
- (void)didSelectDecorateViewOfUUID:(NSUUID *)uuid selected:(BOOL)selected;
- (void)didUpdateDecorateViewOfUUID:(NSUUID *)uuid frame:(CGRect)frame;
- (void)didDeleteDecorateViewOfUUID:(NSUUID *)uuid;

@end

@protocol DecorateDisplayViewDataSource <NSObject>
@required
- (DecorateView *)decorateDisplayView:(DecorateDisplayView *)decorateDisplayView decorateViewOfUUID:(NSUUID *)uuid;

@end