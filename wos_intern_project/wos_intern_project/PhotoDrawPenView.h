//
//  PhotoEditorDrawViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SmoothLineView.h"

@protocol PhotoDrawPenViewDelegate;

@interface PhotoDrawPenView : UIView

@property (nonatomic, weak) id<PhotoDrawPenViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet SmoothLineView *canvasView;

- (IBAction)backAction:(id)sender;
- (IBAction)doneAction:(id)sender;

@end

/**
 그림을 그리는 View에서 발생하는 일을 처리하기 위한 Delegate이다.
 그림 그리기가 완료/취소되었을 때의 상황을 Delegate로 전파한다.
 */
@protocol PhotoDrawPenViewDelegate <NSObject>
@required
/**
 그림 그리기가 완료되었을 때 그려진 Path의 경계를 계산하여, Capture한 UIImage를 전달한다.
 */
- (void)drawPenViewDidFinished:(PhotoDrawPenView *)drawPenView WithImage:(UIImage *)image;
/**
 그림 그리기가 취소되었을 때 이를 알린다.
 */
- (void)drawPenViewDidCancelled:(PhotoDrawPenView *)drawPenView;

@end