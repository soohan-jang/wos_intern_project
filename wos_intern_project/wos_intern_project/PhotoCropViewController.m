//
//  PhotoCropViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 25..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoCropViewController.h"

#import "PECropView.h"
#import "PhotoCropFilterViewCell.h"

#import "ImageUtility.h"
#import "ProgressHelper.h"

@interface PhotoCropViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *cropAreaView;
@property (weak, nonatomic) IBOutlet UIScrollView *filterListScrollView;

@property (strong, nonatomic) PECropView *cropView;
@property (strong, nonatomic) UIImage *croppedImage;
@property (weak, nonatomic) IBOutlet UICollectionView *filterCollectionView;

@property (nonatomic, strong) WMProgressHUD *progressView;

@end

@implementation PhotoCropViewController


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupImage];
    
    [self.filterCollectionView reloadData];
}

- (void)dealloc {
    self.imageUrl = nil;
    self.fullscreenImage = nil;
    self.croppedImage = nil;
}


#pragma mark - Setup Method

- (void)setupImage {
    self.cropView = [[PECropView alloc] initWithFrame:self.cropAreaView.bounds];
    [self.cropAreaView addSubview:self.cropView];
    
    if (self.imageUrl == nil) {
        if (self.fullscreenImage != nil) {
            [self.cropView setImage:self.fullscreenImage];
            self.cropView.imageCropRect = CGRectMake(0, 0, self.cropAreaSize.width, self.cropAreaSize.height);
        } else {
            //Error.
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        self.progressView = [ProgressHelper showProgressAddedTo:self.navigationController.view titleKey:@"progress_title_loadding"];
        
        __weak typeof(self) weakSelf = self;
        [ImageUtility fullscreenImageAtURL:self.imageUrl
                               resultBlock:^(UIImage *image) {
                                   __strong typeof(weakSelf) self = weakSelf;
                                   
                                   if (!self) {
                                       return;
                                   }
                                   
                                   if (image == nil) {
                                       //error
                                   } else {
                                       self.fullscreenImage = image;
                                       [self.cropView setImage:image];
                                       self.cropView.imageCropRect = CGRectMake(0, 0, self.cropAreaSize.width, self.cropAreaSize.height);
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
            [self.delegate cropViewControllerDidFinished:self
                                     withFullscreenImage:self.fullscreenImage
                                        withCroppedImage:self.croppedImage];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout Delegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCropFilterViewCell *cell = (PhotoCropFilterViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.cropView setImage:cell.imageView.image];
}

                      
#pragma mark - UICollectionView DataSource Methods

NSInteger const NumberOfFilterViewCell = 9;

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return NumberOfFilterViewCell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCropFilterViewCell *cell = (PhotoCropFilterViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotoCropFilterViewCell class])
                                                                              forIndexPath:indexPath];
    NSInteger filterType = indexPath.item;
    [cell.imageView setImage:[ImageUtility filteredImage:self.fullscreenImage filterType:filterType]];
    [cell.filterLabel setText:[ImageUtility nameOfFilterType:filterType]];
    
     return cell;
}

@end
