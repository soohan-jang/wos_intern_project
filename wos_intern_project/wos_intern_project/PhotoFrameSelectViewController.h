//
//  PhotoFrameSelectViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ConnectionManager.h"
#import "PhotoEditorViewController.h"
#import "WMProgressHUD.h"

@interface PhotoFrameSelectViewController : UIPageViewController <UIPageViewControllerDelegate>

@property (nonatomic, getter=isEnableFrameSelect) BOOL isEnableFrameSelect;

@property (nonatomic, strong) WMProgressHUD *progressView;

- (IBAction)backAction:(id)sender;
- (IBAction)doneAction:(id)sender;

/**
 NotificationCenter에 필요한 Observer를 등록한다.
 액자 변경, 액자 좋아요, 액자 선택에 대한 인덱스 수신을 처리하기 위한 Observer를 등록한다.
 */
- (void)addObservers;

/**
 NotificationCenter에 등록한 Observer를 등록해제한다.
 액자 변경, 액자 좋아요, 액자 선택에 대한 인덱스 수신을 처리하기 위한 Observer를 등록해제한다.
 */
- (void)removeObservers;

/**
 ProgressView의 상태를 완료로 바꾼 뒤에 종료한다.
 Main Thread에서 호출하기 위한 performSelector 용도의 함수이다.
 */
- (void)doneProgress;

/**
 PhotoEditor ViewController를 호출한다.
 Main Thread에서 호출하기 위한 performSelector 용도의 함수이다.
 */
- (void)loadPhotoEditorViewController;

/**
 상대방이 보는 액자가 변경되었을 때 호출되는 함수이다. 이 함수는 NotificationCenter에 의해 호출된다.
 */
- (void)receivedFrameIndexChanged:(NSNotification *)notification;

/**
 상대방이 보고 있는 액자에 대해서 호의를 표현했을 때 호출되는 함수이다. 이 함수는 NotificationCenter에 의해 호출된다.
 */
 - (void)receivedFrameLiked:(NSNotification *)notification;
 
/**
 상대방이 액자를 선택 완료했을 때 호출되는 함수이다. 이 함수는 NotificationCenter에 의해 호출된다.
 */
- (void)receivedFrameSelected:(NSNotification *)notification;

@end
