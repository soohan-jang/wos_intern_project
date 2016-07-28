//
//  PhotoCropViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 25..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoCropViewController.h"

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
                NSLog(@"이미지를 가져오지 못함.");
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
    if (self.delegate != nil) {
        [self.delegate photoCropViewControllerDidCancel:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)doneAction:(id)sender {
    if (self.delegate != nil) {
        self.croppedImage = [self.cropView croppedImage];
        
        if (self.fullscreenImage != nil && self.croppedImage != nil) {
            [self.delegate photoCropViewController:self didFinishCropImageWithImage:self.fullscreenImage croppedImage:self.croppedImage targetCellIndex:self.targetCellIndex];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)loadProgress {
    if (self.progressView == nil) {
        self.progressView = [WMProgressHUD showHUDAddedTo:self.view animated:YES title:@"불러오는 중..."];
    }
}

- (void)doneProgress {
    if (!self.progressView.isHidden) {
//        [self.progressView doneProgressWithTitle:@"불러오는 중..." delay:1];
        [self.progressView dismissProgress];
    }
}

/**** UIAlertView Delegate Methods ****/
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}

@end
