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

- (void)addObservers {
    
}

- (void)removeObservers {
    
}

- (void)setFrameIndex:(NSUInteger)frameIndex {
    self.collectionView.frameIndex = frameIndex;
}

/**** CollectionViewController DataSource Methods ****/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.collectionView numberOfItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.collectionView cellForItemAtIndexPath:indexPath];
}

/**** CollectionViewController Delegate Flowlayout Methods ****/

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.collectionView sizeForItemAtIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return [self.collectionView insetForCollectionView];
    
    /*
     //셀의 높이는 너비와 같다. 셀은 가로로 4개가 배치되므로, 셀 너비값의 4배가 각 셀의 높이를 합한 값이 된다.
     CGFloat cellBetweenSpace = 20 * 2;
     CGFloat cellsHeight = ((self.collectionView.bounds.size.width - cellBetweenSpace) / 3) * 4;
     //셀 간의 간격은 3곳이 생기며, 라인 간 간격은 20으로 정의되어 있다.
     CGFloat cellsBetweenSpace = 20 * 3;
     //남은 공간의 절반을 상단의 inset으로 지정하면, 수직으로 중간에 정렬시킬 수 있다.
     CGFloat topInset = (self.collectionView.bounds.size.height - cellsHeight - cellsBetweenSpace - 66) / 2;
     
     return UIEdgeInsetsMake(topInset, 0, 0, 0);
     */
}

@end
