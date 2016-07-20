//
//  PhotoEditorViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ConnectionManager.h"
#import "MessageSyncManager.h"

#import "MainViewController.h"
#import "PhotoEditorCollectionView.h"
#import "RFQuiltLayout.h"
#import "PhotoEditorFrameViewCell.h"

typedef NS_ENUM(NSInteger, PhotoEditorAlertType) {
    ALERT_NOT_SAVE = 0,
    ALERT_CONTINUE = 1
};

@interface PhotoEditorViewController : UIViewController <UICollectionViewDataSource, RFQuiltLayoutDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet PhotoEditorCollectionView *collectionView;
@property (nonatomic) NSInteger photoFrameKind;
@property (nonatomic, strong) UITapGestureRecognizer *scrollTapGestureRecognizer;
@property (nonatomic) NSIndexPath *selectedPhotoFrameIndex;

- (IBAction)backAction:(id)sender;
- (IBAction)saveAction:(id)sender;

- (IBAction)photoButtonAction:(id)sender;
- (IBAction)penButtonAction:(id)sender;
- (IBAction)textButtonAction:(id)sender;
- (IBAction)stickerButtonAction:(id)sender;
- (IBAction)eraserButtonAction:(id)sender;

- (void)addObservers;
- (void)removeObservers;

- (void)selectedCellAction:(NSNotification *)notification;

- (void)receivedPhotoInsert:(NSNotification *)notification;
- (void)receivedPhotoDelete:(NSNotification *)notification;
- (void)receivedSessionDisconnected:(NSNotification *)notification;

@end
