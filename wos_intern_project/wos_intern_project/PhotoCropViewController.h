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

@property (weak, nonatomic) id<PhotoCropViewControllerDelegate> delegate;
@property (strong, nonatomic) NSURL *imageUrl;
@property (strong, nonatomic) UIImage *fullscreenImage;
@property (strong, nonatomic) UIImage *croppedImage;

@property (assign, nonatomic) CGSize cellSize;

@property (assign, nonatomic) NSInteger targetCellIndex;

- (IBAction)backAction:(id)sender;
- (IBAction)doneAction:(id)sender;

- (void)loadProgress;
- (void)doneProgress;

@end

@protocol PhotoCropViewControllerDelegate
@required
- (void)photoCropViewController:(PhotoCropViewController *)controller didFinishCropImageWithImage:(UIImage *)fullscreenImage croppedImage:(UIImage *)croppedImage targetCellIndex:(NSInteger)targetCellIndex;
- (void)photoCropViewControllerDidCancel:(PhotoCropViewController *)controller;

@end