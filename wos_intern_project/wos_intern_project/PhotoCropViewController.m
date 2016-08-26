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
#import "ColorUtility.h"
#import "ProgressHelper.h"

NSInteger const NumberOfFilterViewCell = 9;

@interface PhotoCropViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *cropAreaView;
@property (weak, nonatomic) IBOutlet UICollectionView *filterCollectionView;
@property (strong, nonatomic) PECropView *cropView;

@property (assign, nonatomic) CGSize cropAreaSize;
@property (strong, nonatomic) NSURL *imageUrl;
@property (strong, nonatomic) NSMutableArray<UIImage *> *filterImageArray;
@property (assign, nonatomic) NSInteger selectedFilterType;

@property (nonatomic, strong) WMProgressHUD *progressView;

@end

@implementation PhotoCropViewController


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.imageUrl && !self.filterImageArray) {
        //Error.
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [self setupCropView];
    
    if (self.imageUrl) {
        [self loadImageAtAssetsLibrary];
        return;
    }
    
    if (self.filterImageArray && self.filterImageArray.count > 0) {
        [self.cropView setImage:self.filterImageArray[self.selectedFilterType]];
        self.cropView.imageCropRect = CGRectMake(0, 0, self.cropAreaSize.width, self.cropAreaSize.height);
        return;
    }
}

- (void)dealloc {
    [self.cropView removeFromSuperview];
    self.cropView = nil;
    
    self.imageUrl = nil;
    
    [self.filterImageArray removeAllObjects];
    self.filterImageArray = nil;
    
    self.progressView = nil;
}


#pragma mark - Setup Method

- (void)setImage:(UIImage *)image {
    [self setImage:image filiterType:0];
}

- (void)setImage:(UIImage *)image filiterType:(NSInteger)filterType {
    if (!image) {
        return;
    }
    
    [self makeFilteredImages:image];
    self.selectedFilterType = filterType;
}

- (void)setCropAreaSize:(CGSize)size {
    _cropAreaSize = size;
}

- (void)setImageUrl:(NSURL *)url {
    _imageUrl = url;
    self.selectedFilterType = 0;
}

- (void)makeFilteredImages:(UIImage *)image {
    if (self.filterImageArray) {
        [self.filterImageArray removeAllObjects];
        self.filterImageArray = nil;
    }
    
    self.filterImageArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < NumberOfFilterViewCell; i++) {
        [self.filterImageArray addObject:[ImageUtility filteredImage:image filterType:i]];
    }
}

- (void)setupCropView {
    self.cropView = [[PECropView alloc] initWithFrame:self.cropAreaView.bounds];
    [self.cropAreaView addSubview:self.cropView];
}

- (void)loadImageAtAssetsLibrary {
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
                                   [self.navigationController popViewControllerAnimated:YES];
                                   return;
                               }
                               
                               [self makeFilteredImages:image];
                               [self.cropView setImage:image];
                               self.cropView.imageCropRect = CGRectMake(0, 0, self.cropAreaSize.width, self.cropAreaSize.height);
                               
                               [self.filterCollectionView reloadData];
                               
                               [ProgressHelper dismissProgress:self.progressView];
                           }
     ];
}


#pragma mark - EventHandle Methods

- (IBAction)backButtonTapped:(id)sender {
    if (self.delegate) {
        [self.delegate cropViewControllerDidCancelled];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)doneButtonTapped:(id)sender {
    if (self.delegate) {
        UIImage *croppedImage = [self.cropView croppedImage];
        
        if (croppedImage != nil) {
            [self.delegate cropViewControllerDidFinished:self.filterImageArray[0]
                                            croppedImage:croppedImage
                                              filterType:self.selectedFilterType];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout Delegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCropFilterViewCell *cell = (PhotoCropFilterViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.cropView setImage:cell.imageView.image];
    self.selectedFilterType = indexPath.item;
}

                      
#pragma mark - UICollectionView DataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return NumberOfFilterViewCell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCropFilterViewCell *cell = (PhotoCropFilterViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotoCropFilterViewCell class])
                                                                              forIndexPath:indexPath];
    NSInteger filterType = indexPath.item;
    
    [cell.imageView setImage:self.filterImageArray[indexPath.item]];
    [cell.filterLabel setBackgroundColor:[ColorUtility colorWithName:ColorNameTransparent2f]];
    [cell.filterLabel setText:[ImageUtility nameOfFilterType:filterType]];
    
     return cell;
}

@end
