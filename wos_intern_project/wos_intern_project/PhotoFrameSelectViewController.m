//
//  PhotoFrameSelectViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//
#import "PhotoFrameSelectViewController.h"

@implementation PhotoFrameSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [self addObservers];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self removeObservers];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [[ConnectionManager sharedInstance] disconnectSession];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneAction:(id)sender {
    if (self.ownSelectedFrameIndex == nil && self.connectedPeerSelectedFrameIndex == nil) {
        //Alert. 둘 중 한명은 액자를 선택해야됨
    }
    else {
        [self performSegueWithIdentifier:@"moveToPhotoEditor" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"moveToPhotoEditor"]) {
        PhotoEditorViewController *viewController = [segue destinationViewController];
        [viewController setupUI:@[self.ownSelectedFrameIndex, self.connectedPeerSelectedFrameIndex]];
    }
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFrameSelected:) name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_PHOTO_FRAME_SELECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFrameDeselected:) name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_PHOTO_FRAME_DESELECTED object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_PHOTO_FRAME_SELECTED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_PHOTO_FRAME_DESELECTED object:nil];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoFrameSelectViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"frameCell" forIndexPath:indexPath];
    [cell.frameButton setImage:[UIImage imageNamed:@"frame_sample"] forState:UIControlStateNormal];
    [cell.frameButton setImage:[UIImage imageNamed:@"frame_sample_slt"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (self.collectionView.bounds.size.width - (5 * 3)) / 4;
    return CGSizeMake(width, width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSLog(@"11");
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

/*** Session Communication Methods ****/

- (void)sendFrameSelected {
    
}

- (void)sendFrameDeselect {
    
}

- (void)receivedFrameSelected:(NSNotification *)notification {
    
    
//    [self performSelectorOnMainThread:@selector(doneProgress) withObject:nil waitUntilDone:YES];
//    //ProgressView의 상태가 바뀌어서 사용자에게 보여질정도의 충분한 시간(delay + 0.5) 뒤에 PhotoEditorViewController를 호출하도록 한다.
//    [self performSelectorOnMainThread:@selector(doneProgress) withObject:nil waitUntilDone:YES];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self performSelectorOnMainThread:@selector(loadPhotoEditorViewController) withObject:nil waitUntilDone:YES];
//    });
}

- (void)receivedFrameDeselected:(NSNotification *)notification {

}

@end
