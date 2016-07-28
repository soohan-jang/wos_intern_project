//
//  PhotoEditorViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ConnectionManager.h"
#import "MessageSyncManager.h"

#import "SphereMenu.h"

#import "MainViewController.h"
#import "PhotoFrameCellManager.h"
#import "PhotoEditorFrameViewCell.h"
#import "PhotoCropViewController.h"

typedef NS_ENUM(NSInteger, PhotoEditorAlertType) {
    ALERT_NOT_SAVE = 0,
    ALERT_CONTINUE = 1
};

@interface PhotoEditorViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SphereMenuDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoCropViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *collectionContainerView;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) PhotoFrameCellManager *cellManager;

@property (atomic, assign) NSIndexPath *selectedIndexPath;
@property (atomic, strong) NSURL *selectedImageURL;

@property (nonatomic, assign) BOOL isMenuAppear;

/**
 네비게이션바에 위치한 "뒤로" 버튼을 눌렀을 때의 처리를 담당하는 함수이다.
 */
- (IBAction)backAction:(id)sender;

/**
 네비게이션바에 위치한 "저장" 버튼을 눌렀을 때의 처리를 담당하는 함수이다.
 */
- (IBAction)saveAction:(id)sender;

//각각의 메뉴에 대응한다.
- (IBAction)penButtonAction:(id)sender;
- (IBAction)textButtonAction:(id)sender;
- (IBAction)stickerButtonAction:(id)sender;
- (IBAction)eraserButtonAction:(id)sender;

/**
 NotificationCenter가 알리는 Notification을 처리하기 위한 Observer들을 등록한다.
 */
- (void)addObservers;

/**
 NotificationCenter가 알리는 Notification을 처리하기 위한 Observer들을 등록 해제한다.
 */
- (void)removeObservers;

- (void)setPhotoFrameNumber:(NSInteger)frameNumber;
- (void)reloadData;

/**
 상대방이 사진을 전송할 때 호출되는 함수이다. 상대방이 사진을 보낼 때, 시작되는 시점과 종료되는 시점을 구분하여 로직이 처리된다.
 */
- (void)receivedPhotoInsert:(NSNotification *)notification;

/**
 상대방이 사진 수신을 종료했음을 알릴 때 호출되는 함수이다.
 */
- (void)receivedPhotoInsertAck:(NSNotification *)notification;

- (void)receivedPhotoEdit:(NSNotification *)notification;
- (void)receivedPhotoEditCanceled:(NSNotification *)notification;

/**
 상대방이 사진을 삭제했을 때 호출되는 함수이다.
 */
- (void)receivedPhotoDelete:(NSNotification *)notification;
- (void)receivedSessionDisconnected:(NSNotification *)notification;

@end
