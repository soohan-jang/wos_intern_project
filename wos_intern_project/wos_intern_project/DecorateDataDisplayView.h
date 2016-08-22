//
//  DecorateDataDisplayView.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecorateView.h"

@protocol DecorateDataDisplayViewDelegate;
@protocol DecorateDataDisplayViewDataSource;

@interface DecorateDataDisplayView : UIView

@property (weak, nonatomic) id<DecorateDataDisplayViewDelegate> delegate;
@property (weak, nonatomic) id<DecorateDataDisplayViewDataSource> dataSource;

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
@protocol DecorateDataDisplayViewDelegate <NSObject>
@required
- (void)didSelectDecorateViewOfUUID:(NSUUID *)uuid selected:(BOOL)selected;
- (void)didUpdateDecorateViewOfUUID:(NSUUID *)uuid frame:(CGRect)frame;
- (void)didDeleteDecorateViewOfUUID:(NSUUID *)uuid;

@end

@protocol DecorateDataDisplayViewDataSource <NSObject>
@required
- (DecorateView *)decorateDisplayView:(DecorateDataDisplayView *)decorateDisplayView decorateViewOfUUID:(NSUUID *)uuid;

@end