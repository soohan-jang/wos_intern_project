//
//  PhotoDrawPenMenuView.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoDrawPenMenuViewDelegate;

@interface PhotoDrawPenMenuView : UIView

@property (weak, nonatomic) id<PhotoDrawPenMenuViewDelegate> delegate;

@end

/**
 그림을 그리는 View에서 발생하는 일을 처리하기 위한 Delegate이다.
 그림 그리기가 완료/취소되었을 때의 상황을 Delegate로 전파한다.
 */
@protocol PhotoDrawPenMenuViewDelegate <NSObject>
@required
/**
 그림 그리기가 완료되었을 때 그려진 Path의 경계를 계산하여, Capture한 UIImage를 전달한다.
 */
- (void)drawPenMenuViewDidFinished:(PhotoDrawPenMenuView *)drawPenMenuView WithImage:(UIImage *)image;
/**
 그림 그리기가 취소되었을 때 이를 알린다.
 */
- (void)drawPenMenuViewDidCancelled:(PhotoDrawPenMenuView *)drawPenMenuView;

@end