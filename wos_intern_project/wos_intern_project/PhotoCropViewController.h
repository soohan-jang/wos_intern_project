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

@interface PhotoCropViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *cropAreaView;
@property (weak, nonatomic) IBOutlet UIScrollView *filterListScrollView;


@property (weak, nonatomic) id<PhotoCropViewControllerDelegate> delegate;
@property (assign, nonatomic) CGSize cellSize;
@property (strong, nonatomic) NSURL *imageUrl;
@property (strong, nonatomic) UIImage *fullscreenImage;

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)doneButtonTapped:(id)sender;

@end

/**
 사진을 편집하는 ViewController의 Delegate이다.
 이 Delegate는 작업이 완료되었을 때와 취소되었을 때의 메시지를 전달한다.
 */
@protocol PhotoCropViewControllerDelegate <NSObject>
@required
/**
 편집이 완료된 후에 원본 이미지와 편집된 이미지를 전달한다.
 */
- (void)cropViewControllerDidFinished:(PhotoCropViewController *)controller withFullscreenImage:(UIImage *)fullscreenImage withCroppedImage:(UIImage *)croppedImage;
/**
 편집이 취소되었음을 알린다.
 */
- (void)cropViewControllerDidCancelled:(PhotoCropViewController *)controller;

@end