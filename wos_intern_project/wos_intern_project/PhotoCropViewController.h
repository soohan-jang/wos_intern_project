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

@protocol PhotoCropViewControllerDelegate;

@interface PhotoCropViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *cropAreaView;
@property (strong, nonatomic) IBOutlet UIScrollView *filterListScrollView;

@property (strong, nonatomic) PECropView *cropView;

@property (nonatomic, weak) id<PhotoCropViewControllerDelegate> delegate;
@property (strong, nonatomic) NSURL *imageUrl;
@property (copy, nonatomic) NSString *filename;
@property (strong, nonatomic) NSURL *croppedImageUrl, *resizedImageUrl;
@property (assign, nonatomic) CGSize cellSize;

- (IBAction)backAction:(id)sender;
- (IBAction)doneAction:(id)sender;

- (void)loadProgress;
- (void)doneProgress;

@end

@protocol PhotoCropViewControllerDelegate
@required
- (void)cropViewController:(PhotoCropViewController *)controller didFinishCroppingImageWithFilename:(NSString *)filename croppedImagePath:(NSURL *)croppedImagePath originalImagePath:(NSURL *)originalImagePath;
- (void)cropViewControllerDidCancel:(PhotoCropViewController *)controller;

@end