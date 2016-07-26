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
    
    if (self.imageUrl == nil) {
        //return
    }
    else {
        self.cropView = [[PECropView alloc] initWithFrame:self.cropAreaView.bounds];
        [self.cropAreaView addSubview:self.cropView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadProgress];
            
            if (self.assetslibrary == nil) {
                self.assetslibrary = [[ALAssetsLibrary alloc] init];
            }
            
            [self.assetslibrary assetForURL:self.imageUrl resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                self.filename = representation.filename;
                if ([[ImageUtility sharedInstance] makeTempImageWithFilename:self.filename resizeOption:IMAGE_RESIZE_STANDARD]) {
                    self.resizedImageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), representation.filename, FILE_POSTFIX_STANDARD]];
                    UIImage *standardImage = [UIImage imageWithContentsOfFile:self.resizedImageUrl.absoluteString];
                    
                    self.cropView.image = standardImage;
                }
                
                [self doneProgress];
            } failureBlock:nil];
        });
    }
}

- (IBAction)backAction:(id)sender {
    if (self.delegate != nil) {
        [self.delegate cropViewControllerDidCancel:self];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneAction:(id)sender {
    if (self.delegate != nil) {
        UIImage *croppedImage = [self.cropView croppedImage];
        
        if ([[ImageUtility sharedInstance] makeTempImageWithUIImage:croppedImage filename:self.filename prefixOption:IMAGE_RESIZE_CROPPED]) {
            NSURL *croppedImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), self.filename, FILE_POSTFIX_CROPPED]];
            [self.delegate cropViewController:self didFinishCroppingImageWithFilename:self.filename croppedImagePath:croppedImageURL originalImagePath:self.resizedImageUrl];
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
