//
//  PhotoEditorViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CommonConstants.h"

#import "ConnectionManager.h"
#import "MessageSyncManager.h"
#import "DecorateObjectManager.h"

#import "SphereMenu.h"
#import "XXXRoundMenuButton.h"

#import "MainViewController.h"
#import "PhotoFrameCellManager.h"
#import "PhotoEditorFrameViewCell.h"
#import "PhotoCropViewController.h"
#import "PhotoDrawObjectDisplayView.h"
#import "PhotoDrawPenView.h"

typedef NS_ENUM(NSInteger, PhotoEditorAlertType) {
    ALERT_NOT_SAVE   = 0,
    ALERT_CONTINUE   = 1,
    ALERT_ALBUM_AUTH = 2
};

@interface PhotoEditorViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SphereMenuDelegate, XXXRoundMenuButtonDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoCropViewControllerDelegate, PhotoDrawObjectDisplayViewDelegate, PhotoDrawPenViewDelegate, UIAlertViewDelegate, ConnectionManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *collectionContainerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet XXXRoundMenuButton *editMenuButton;

//그려진 객체들이 위치하는 뷰
@property (weak, nonatomic) IBOutlet PhotoDrawObjectDisplayView *drawObjectDisplayView;
//그려질 객체들이 위치하는 뷰(실제로 그림을 그리는 뷰)
@property (weak, nonatomic) IBOutlet PhotoDrawPenView *drawPenView;

/**
 네비게이션바에 위치한 "뒤로" 버튼을 눌렀을 때의 처리를 담당하는 함수이다.
 */
- (IBAction)backAction:(id)sender;

/**
 네비게이션바에 위치한 "저장" 버튼을 눌렀을 때의 처리를 담당하는 함수이다.
 */
- (IBAction)saveAction:(id)sender;

/**
 선택된 사진 액자를 전달한다. 파라메터는 NSInteger로 선택된 사진 액자의 indexPath.item을 받는다.
 전달된 indexPath.item의 값에 따라 정해진 사진 액자를 구성하도록 설정한다.
 */
- (void)setPhotoFrameNumber:(NSInteger)frameNumber;

@end
