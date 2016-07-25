//
//  PhotoCropViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 25..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WMProgressHUD.h"
#import "PECropView.h"
#import "ImageUtility.h"

extern NSString *const NOTIFICATION_POP_PHOTO_EDITOR_VIEW_CONTROLLER;

@protocol PhotoCropViewControllerDelegate;

@interface PhotoCropViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id<PhotoCropViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet PECropView *cropView;
@property (strong, nonatomic) NSURL *imageUrl;
@property (assign, nonatomic) CGSize cellSize;

- (void)viewDidUnwind:(NSNotification *)notification;

- (IBAction)backAction:(id)sender;
- (IBAction)doneAction:(id)sender;

- (void)loadProgress;
- (void)doneProgress;

@end

@protocol PhotoCropViewControllerDelegate
@required
- (void)cropViewController:(PhotoCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage originalImagePath:(NSString *)originalImagePath;
- (void)cropViewControllerDidCancel:(PhotoCropViewController *)controller;

@end