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
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    self.ownSelectedFrameIndex = nil;
    self.connectedPeerSelectedFrameIndex = nil;
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
    if (self.ownSelectedFrameIndex == nil || self.connectedPeerSelectedFrameIndex == nil) {
        //Alert. Browser, Advertiser 모두 액자를 선택해야됨
    }
    else {
        if (self.ownSelectedFrameIndex.item == self.connectedPeerSelectedFrameIndex.item) {
            //Browser, Advertiser가 선택한 액자가 일치함.
            [self performSegueWithIdentifier:@"moveToPhotoEditor" sender:self];
            
            //    [self performSelectorOnMainThread:@selector(doneProgress) withObject:nil waitUntilDone:YES];
            //    //ProgressView의 상태가 바뀌어서 사용자에게 보여질정도의 충분한 시간(delay + 0.5) 뒤에 PhotoEditorViewController를 호출하도록 한다.
            //    [self performSelectorOnMainThread:@selector(doneProgress) withObject:nil waitUntilDone:YES];
            //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //        [self performSelectorOnMainThread:@selector(loadPhotoEditorViewController) withObject:nil waitUntilDone:YES];
            //    });
        }
        else {
            //Alert. Browser, Advertiser가 선택한 액자가 일치하지 않음.
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"moveToPhotoEditor"]) {
        PhotoEditorViewController *viewController = [segue destinationViewController];
        [viewController setupUI:self.ownSelectedFrameIndex.item];
    }
}

- (void)frameStateChangeAtIndex:(NSIndexPath *)indexPath {
    NSIndexPath *prevIndex = self.ownSelectedFrameIndex;
    self.ownSelectedFrameIndex = indexPath;
    
    //본인이 아무것도 선택하지 않은 상태에서, 액자를 선택한 경우이다.
    if (prevIndex == nil) {
        //상대방이 액자를 선택하지 않은 경우면, 본인만 선택한 것으로 변경한다. (Blue Color)
        if (self.connectedPeerSelectedFrameIndex == nil) {
            [self frameImageChangeAtIndex:self.ownSelectedFrameIndex state:1];
        }
        //상대방이 액자를 선택한 경우면, 상대방이 선택한 액자 값에 따라 다르다.
        else {
            //선택된 액자가 상대방이 선택한 액자와 같은 경우, 두 사용자가 모두 선택한 것으로 변경한다. (Green Color)
            if (self.ownSelectedFrameIndex.item == self.connectedPeerSelectedFrameIndex.item) {
                [self frameImageChangeAtIndex:self.ownSelectedFrameIndex state:3];
            }
            //선택한 액자가 상대방이 선택한 액자와 다를 경우, 본인만 선택한 것으로 변경한다.
            else {
                [self frameImageChangeAtIndex:self.ownSelectedFrameIndex state:1];
            }
        }
        
        [self sendFrameSelected];
    }
    else {
        //이전에 선택한 액자와 지금 선택한 액자가 같으면, 선택 해제에 해당한다.
        if (prevIndex.item == self.ownSelectedFrameIndex.item) {
            //상대방이 액자를 선택하지 않은 경우라면 본인만 선택했었던 것이므로, 선택되지 않은 것으로 변경한다. (White Color)
            if (self.connectedPeerSelectedFrameIndex == nil) {
                [self frameImageChangeAtIndex:self.ownSelectedFrameIndex state:0];
            }
            else {
                //선택해제된 항목이 두 사용자가 모두 선택했었던 액자였다면, 상대방만 선택한 것으로 변경한다. (Oranger Color)
                if (self.ownSelectedFrameIndex.item == self.connectedPeerSelectedFrameIndex.item) {
                    [self frameImageChangeAtIndex:self.ownSelectedFrameIndex state:2];
                }
                //선택해제된 항목이 본인만 선택했었던 액자였다면, 선택되지 않은 것으로 변경한다. (White Color)
                else {
                    [self frameImageChangeAtIndex:self.ownSelectedFrameIndex state:0];
                }
            }
            
            [self sendFrameDeselect];
            self.ownSelectedFrameIndex = nil;
        }
        //이전에 선택한 액자와 지금 선택한 액자가 다르면, 선택에 해당한다.
        else {
            //상대방이 액자를 선택하지 않은 경우라면, 본인만 선택한 것으로 변경한다. (Blue Color)
            //또한 상대방이 액자를 선택하지 않았으므로, 이전에 선택했던 액자는 선택되지 않음으로 변경한다. (White Color)
            if (self.connectedPeerSelectedFrameIndex == nil) {
                [self frameImageChangeAtIndex:prevIndex state:0];
                [self frameImageChangeAtIndex:self.ownSelectedFrameIndex state:1];
            }
            else {
                //선택된 항목이 상대방 사용자가 이미 선택한 액자라면, 두 사용자가 모두 선택한 것으로 변경한다. (Green Color)
                if (self.ownSelectedFrameIndex.item == self.connectedPeerSelectedFrameIndex.item) {
                    //이 경우 이전에 선택되었던 액자는 아무도 선택하지 않은 것이 되므로, 이전에 선택했던 액자는 선택되지 않는 것으로 변경한다. (White Color)
                    [self frameImageChangeAtIndex:prevIndex state:0];
                    [self frameImageChangeAtIndex:self.ownSelectedFrameIndex state:3];
                }
                //선택된 항목이 상대방 사용자가 선택하지 않은 액자라면, 본인만 선택한 것으로 변경한다. (Blue Color)
                else {
                    //이 경우 이전에 선택되었던 액자는 상대방 선택 값에 따라 달라진다.
                    //이전에 선택했던 액자가 두 사용자가 모두 선택했었던 액자였다면, 상대방만 선택한 것으로 변경한다. (Oranger Color)
                    if (prevIndex.item == self.connectedPeerSelectedFrameIndex.item) {
                        [self frameImageChangeAtIndex:prevIndex state:2];
                    }
                    //그렇지 않다면 이전에 선택했던 액자는 본인만 선택헀던 액자이므로, 선택되지 않은 것으로 변경한다. (White Color)
                    else {
                        [self frameImageChangeAtIndex:prevIndex state:0];
                    }
                    
                    [self frameImageChangeAtIndex:self.ownSelectedFrameIndex state:1];
                }
            }
            
            [self sendFrameSelected];
        }
    }
}

- (void)frameImageChangeAtIndex:(NSIndexPath *)indexPath state:(NSUInteger)state {
    PhotoFrameSelectViewCell *cell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell setImageWithIndex:indexPath.item State:state];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFrameSelected:) name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_PHOTO_FRAME_SELECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFrameDeselected:) name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_PHOTO_FRAME_DESELECTED object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_PHOTO_FRAME_SELECTED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[ConnectionManager sharedInstance].NOTIFICATION_RECV_PHOTO_FRAME_DESELECTED object:nil];
}

/**** CollectionViewController DataSource Methods ****/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoFrameSelectViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"frameSelectCell" forIndexPath:indexPath];
    [cell.frameImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"PhotoFrame%ld", indexPath.item]]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self frameStateChangeAtIndex:indexPath];
}

/**** CollectionViewController Delegate Flowlayout Methods ****/

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //한 라인에 셀 3개를 배치한다. 따라서 셀 간의 간격은 2곳이 생긴다.
    CGFloat cellBetweenSpace = 20 * 2;
    CGFloat cellWidth = (self.collectionView.bounds.size.width - cellBetweenSpace) / 3;
    return CGSizeMake(cellWidth, cellWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    //셀의 높이는 너비와 같다. 셀은 가로로 4개가 배치되므로, 셀 너비값의 4배가 각 셀의 높이를 합한 값이 된다.
    CGFloat cellsHeight = (self.collectionView.bounds.size.width - (20 * 2)) / 3 * 4;
    //셀 간의 간격은 3곳이 생기며, 라인 간 간격은 20으로 정의되어 있다.
    CGFloat cellsBetweenSpace = 20 * 3;
    //남은 공간의 절반을 상단의 inset으로 지정하면, 수직으로 중간에 정렬시킬 수 있다.
    CGFloat topInset = (self.collectionView.bounds.size.height - cellsHeight - cellsBetweenSpace) / 2;
    
    return UIEdgeInsetsMake(topInset, 0, 0, 0);
}

/*** Session Communication Methods ****/

- (void)sendFrameSelected {
    NSDictionary *sendData = @{[ConnectionManager sharedInstance].KEY_DATA_TYPE: [ConnectionManager sharedInstance].VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED,
                               [ConnectionManager sharedInstance].KEY_PHOTO_FRAME_SELECTED: self.ownSelectedFrameIndex};
    [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
}

- (void)sendFrameDeselect {
    NSDictionary *sendData = @{[ConnectionManager sharedInstance].KEY_DATA_TYPE: [ConnectionManager sharedInstance].VALUE_DATA_TYPE_PHOTO_FRAME_DESELECTED};
    [[ConnectionManager sharedInstance] sendData:[NSKeyedArchiver archivedDataWithRootObject:sendData]];
}

- (void)receivedFrameSelected:(NSNotification *)notification {

}

- (void)receivedFrameDeselected:(NSNotification *)notification {
    NSIndexPath *deselectConnectedPeerIndexPath = [notification.userInfo objectForKey:[ConnectionManager sharedInstance].KEY_PHOTO_FRAME_DESELECTED];
    PhotoFrameSelectViewCell *currentConnecedPeerSltCell = (PhotoFrameSelectViewCell *)[self.collectionView cellForItemAtIndexPath:deselectConnectedPeerIndexPath];
    [currentConnecedPeerSltCell.frameImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"PhotoFrame%ld", deselectConnectedPeerIndexPath.item]]];
    
    self.connectedPeerSelectedFrameIndex = nil;
}

@end
