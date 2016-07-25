//
//  PhotoCropViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 25..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoCropViewController.h"

NSString *const NOTIFICATION_POP_PHOTO_EDITOR_VIEW_CONTROLLER = @"popPhotoEditorViewController";

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
        
        
        self.cropView = [[PECropView alloc] initWithFrame:self.view.bounds];
        self.cropView.keepingCropAspectRatio = YES;
        self.cropView.marginTop = (self.view.frame.size.height - self.cellSize.height) / 4.0f;
        self.cropView.marginLeft = (self.view.frame.size.width - self.cellSize.width) / 4.0;
        [self.view addSubview:self.cropView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadProgress];
            
            if (self.assetslibrary == nil) {
                self.assetslibrary = [[ALAssetsLibrary alloc] init];
            }
            
            [self.assetslibrary assetForURL:self.imageUrl resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                
                if ([[ImageUtility sharedInstance] makeTempImageWithFilename:representation.filename resizeOption:IMAGE_RESIZE_STANDARD]) {
                    
                    
                    UIImage *standardImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), representation.filename, FILE_POSTFIX_STANDARD]];
                    [self.cropView setImage:standardImage];
                }
                
                [self doneProgress];
            } failureBlock:nil];
        });
        
    }
    

//    dispatch_async(dispatch_get_main_queue(), ^{
//        [assetslibrary assetForURL:imageUrl resultBlock:^(ALAsset *asset) {
//            ALAssetRepresentation *representation = [asset defaultRepresentation];
//            
//            if ([[ImageUtility sharedInstance] makeTempImageWithFilename:representation.filename resizeOption:IMAGE_RESIZE_STANDARD]) {
//                UIImage *standardImage = [UIImage imageWithContentsOfFile
//                                          :[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), representation.filename, FILE_POSTFIX_STANDARD]];
//                [self.collectionView putImageWithItemIndex:self.selectedPhotoFrameIndex.item Image:standardImage];
//                [self.collectionView reloadData];
//            }
//            
//            [[ConnectionManager sharedInstance] sendResourceDataWithFilename:representation.filename index:self.selectedPhotoFrameIndex.item];
//        } failureBlock:nil];
//    });
//    
//    
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [assetslibrary assetForURL:imageUrl resultBlock:^(ALAsset *asset) {
//                ALAssetRepresentation *representation = [asset defaultRepresentation];
//    
//                [self.collectionView setLoadingStateWithItemIndex:self.selectedPhotoFrameIndex.item State:STATE_UPLOADING];
//    
//                if ([[ImageUtility sharedInstance] makeTempImageWithAssetRepresentation:representation]) {
//                    if ([[ImageUtility sharedInstance] makeTempImageWithFilename:representation.filename resizeOption:IMAGE_RESIZE_THUMBNAIL]) {
//                        UIImage *thumbnailImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), representation.filename, FILE_POSTFIX_THUMBNAIL]];
//                        [self.collectionView putImageWithItemIndex:self.selectedPhotoFrameIndex.item Image:thumbnailImage];
//                        [self.collectionView reloadData];
//                    }
//                }
//            } failureBlock:nil];
//        });
    
    
}

- (void)viewDidUnwind:(NSNotification *)notification {
    
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneAction:(id)sender {

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
