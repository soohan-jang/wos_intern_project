//
//  PhotoCropViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 25..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoCropViewController.h"

#import "PECropView.h"

#import "ImageUtility.h"
#import "ProgressHelper.h"

@interface PhotoCropViewController ()

@property (weak, nonatomic) IBOutlet UIView *cropAreaView;
@property (weak, nonatomic) IBOutlet UIScrollView *filterListScrollView;

@property (strong, nonatomic) PECropView *cropView;
@property (strong, nonatomic) UIImage *croppedImage;

@end

@interface PhotoCropViewController ()

@property (nonatomic, strong) WMProgressHUD *progressView;

@end

@implementation PhotoCropViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCropView];
}

- (void)setupCropView {
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
        self.progressView = [ProgressHelper showProgressAddedTo:self.view titleKey:@"progress_title_loadding"];
        
        [ImageUtility getFullscreenUIImageAthURL:self.imageUrl resultBlock:^(UIImage *image) {
            if (image == nil) {
                //error
            } else {
                self.fullscreenImage = image;
                [self.cropView setImage:image];
                self.cropView.imageCropRect = CGRectMake(0, 0, self.cellSize.width, self.cellSize.height);
            }
            
            [ProgressHelper dismissProgress:self.progressView];
        }];
    }
}


#pragma mark - EventHandle Methods

- (IBAction)backButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cropViewControllerDidCancelled:)]) {
        [self.delegate cropViewControllerDidCancelled:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)doneButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cropViewControllerDidFinished:withFullscreenImage:withCroppedImage:)]) {
        self.croppedImage = [self.cropView croppedImage];
        
        if (self.fullscreenImage != nil && self.croppedImage != nil) {
            [self.delegate cropViewControllerDidFinished:self withFullscreenImage:self.fullscreenImage withCroppedImage:self.croppedImage];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
