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

@interface PhotoCropViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate>


@property (strong, nonatomic) IBOutlet PECropView *cropView;
@property (strong, nonatomic) NSURL *imageUrl;
@property (assign, nonatomic) CGFloat ratio;

- (void)viewDidUnwind:(NSNotification *)notification;

- (IBAction)backAction:(id)sender;
- (IBAction)doneAction:(id)sender;

- (void)loadProgress;
- (void)doneProgress;

@end
