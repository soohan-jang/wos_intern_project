//
//  PhotoCropViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 25..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageUtility.h"

#import "WMProgressHUD.h"
#import "PECropView.h"

@protocol PhotoCropViewControllerDelegate;

@interface PhotoCropViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *cropAreaView;
@property (strong, nonatomic) IBOutlet UIScrollView *filterListScrollView;


@property (weak, nonatomic) id<PhotoCropViewControllerDelegate> delegate;
@property (assign, nonatomic) CGSize cellSize;
@property (strong, nonatomic) NSURL *imageUrl;
@property (strong, nonatomic) UIImage *fullscreenImage;

- (IBAction)backAction:(id)sender;
- (IBAction)doneAction:(id)sender;

@end

@protocol PhotoCropViewControllerDelegate <NSObject>
@required
- (void)cropViewControllerDidFinished:(PhotoCropViewController *)controller withFullscreenImage:(UIImage *)fullscreenImage withCroppedImage:(UIImage *)croppedImage;
- (void)cropViewControllerDidCancelled:(PhotoCropViewController *)controller;

@end