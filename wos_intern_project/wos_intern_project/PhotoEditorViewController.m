//
//  PhotoEditorViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoEditorViewController.h"

@implementation PhotoEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.collectionView.frameIndex = self.frameIndex;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [[ConnectionManager sharedInstance] disconnectSession];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)saveAction:(id)sender {
    [[ConnectionManager sharedInstance] disconnectSession];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)photoButtonAction:(id)sender {
}

- (IBAction)penButtonAction:(id)sender {
}

- (IBAction)textButtonAction:(id)sender {
}

- (IBAction)stickerButtonAction:(id)sender {
}

- (IBAction)eraserButtonAction:(id)sender {
}

- (IBAction)StickerButtonAction:(id)sender {
}

- (void)addObservers {
    
}

- (void)removeObservers {
    
}

/**** CollectionViewController DataSource Methods ****/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.collectionView numberOfItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoEditorFrameViewCell *cell = (PhotoEditorFrameViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell;
}

/**** CollectionViewController Delegate Flowlayout Methods ****/

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.collectionView sizeForItemAtIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return [self.collectionView insetForCollectionView];
}

@end
