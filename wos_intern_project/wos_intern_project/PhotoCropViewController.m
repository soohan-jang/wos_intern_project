//
//  PhotoCropViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 25..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoCropViewController.h"

@interface PhotoCropViewController ()

@property (strong, nonatomic) PECropView *cropView;
@property (strong, nonatomic) UIImage *croppedImage;

- (void)loadProgress;
- (void)doneProgress;

@end

@interface PhotoCropViewController ()

@property (nonatomic, strong) ALAssetsLibrary *assetslibrary;
@property (nonatomic, strong) WMProgressHUD *progressView;

@end

@implementation PhotoCropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cropView = [[PECropView alloc] initWithFrame:self.cropAreaView.bounds];
    [self.cropAreaView addSubview:self.cropView];
    
    if (self.imageUrl == nil) {
        if (self.fullscreenImage != nil) {
            [self.cropView setImage:self.fullscreenImage];
            self.cropView.imageCropRect = CGRectMake(0, 0, self.cellSize.width, self.cellSize.height);
        } else {
            //Error.
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self loadProgress];
        
        [[ImageUtility sharedInstance] getFullScreenUIImageWithURL:self.imageUrl resultBlock:^(UIImage *image) {
            if (image == nil) {
                //error
            } else {
                self.fullscreenImage = image;
                [self.cropView setImage:image];
                self.cropView.imageCropRect = CGRectMake(0, 0, self.cellSize.width, self.cellSize.height);
            }
            
            [self doneProgress];
        }];
    }
}

- (IBAction)backAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cropViewControllerDidCancelled:)]) {
        [self.delegate cropViewControllerDidCancelled:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)doneAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cropViewControllerDidFinished:withFullscreenImage:withCroppedImage:)]) {
        self.croppedImage = [self.cropView croppedImage];
        
        if (self.fullscreenImage != nil && self.croppedImage != nil) {
            [self.delegate cropViewControllerDidFinished:self withFullscreenImage:self.fullscreenImage withCroppedImage:self.croppedImage];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)loadProgress {
    if (self.progressView == nil) {
        self.progressView = [WMProgressHUD showHUDAddedTo:self.view animated:YES title:NSLocalizedString(@"progress_title_loadding", nil)];
    }
}

- (void)doneProgress {
    if (!self.progressView.isHidden) {
        [self.progressView dismissProgress];
    }
}


#pragma  mark - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}

@end
