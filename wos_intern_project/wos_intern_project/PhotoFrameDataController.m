//
//  PhotoFrameDataController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoFrameDataController.h"
#import "SelectPhotoFrameViewCell.h"

#import "SessionManager.h"
#import "MessageSender.h"
#import "MessageReceiver.h"
#import "MessageInterrupter.h"

#import "ImageUtility.h"

NSInteger const NumberOfPhotoFrameCells = 12;

@interface PhotoFrameDataSender ()

@property (strong, nonatomic) MessageSender *messageSender;

@end

@implementation PhotoFrameDataSender

- (BOOL)sendSelectPhotoFrameMessage:(NSIndexPath *)indexPath {
    return [self.messageSender sendSelectPhotoFrameMessage:indexPath];
}

- (BOOL)sendDeselectPhotoFrameMessage:(NSIndexPath *)indexPath {
    return [self.messageSender sendDeselectPhotoFrameMessage:indexPath];
}

- (BOOL)sendPhotoFrameConfrimRequestMessage:(NSIndexPath *)indexPath {
    return [self.messageSender sendPhotoFrameConfrimRequestMessage:indexPath];
}

- (BOOL)sendPhotoFrameConfirmAckMessage:(BOOL)confrimAck {
    return [self.messageSender sendPhotoFrameConfirmAckMessage:confrimAck];
}

@end

@interface PhotoFrameDataController () <UICollectionViewDataSource, MessageReceiverPhotoFrameDataDelegate, MessageInterrupterConfirmRequestDelegate>

@property (strong, atomic) NSMutableArray<PhotoFrameData *> *cellDatas;

@end

@implementation PhotoFrameDataController

- (instancetype)initWithCollectionViewSize:(CGSize)size {
    self = [super init];
    
    if (self) {
        self.cellDatas = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < NumberOfPhotoFrameCells; i++) {
            [self.cellDatas addObject:[[PhotoFrameData alloc] initWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
        }
        
        SessionManager *sessionManager = [SessionManager sharedInstance];
        MessageBuffer *messageBuffer = sessionManager.messageReceiver.messageBuffer;
        
        if (messageBuffer.enabled && !messageBuffer.isMessageBufferEmpty) {
            //동기화 작업을 수행한다.
            while (![messageBuffer isMessageBufferEnabled]) {
                MessageData *data = [messageBuffer getMessage];
                
                if (data.messageType == MessageTypePhotoFrameSelect) {
                    [self setSelectedCellAtIndexPath:data.photoFrameIndexPath isOwnSelection:NO];
                } else if (data.messageType == MessageTypePhotoFrameDeselect) {
                    [self setDeselectedCellAtIndexPath:data.photoFrameIndexPath isOwnSelection:NO];
                }
            }
        }
        
        [messageBuffer setEnabled:NO];
        
        sessionManager.messageReceiver.photoFrameDataDelegate = self;
        [MessageInterrupter sharedInstance].interruptConfirmRequestDelegate = self;
    }
    
    return self;
}

- (void)clearController {
    [self.cellDatas removeAllObjects];
    self.cellDatas = nil;
    
    _ownSelectedIndexPath = nil;
    _otherSelectedIndexPath = nil;
    self.delegate = nil;
}

//isOwnSelection으로 내가 발생시킨 이벤트인지, 상대방에 발생시킨 이벤트인지 파악한다.
- (void)setSelectedCellAtIndexPath:(NSIndexPath *)indexPath isOwnSelection:(BOOL)isOwnSelection {
    if (!indexPath)
        return;
    
    PhotoFrameData *cellData;
    NSIndexPath *prevIndexPath;
    
    if (isOwnSelection) {
        prevIndexPath = self.ownSelectedIndexPath;
    } else {
        prevIndexPath = self.otherSelectedIndexPath;
    }
    
    if (prevIndexPath && prevIndexPath.item != indexPath.item) {
        cellData = self.cellDatas[prevIndexPath.item];
        [cellData updateCellState:NO isOwnSelection:isOwnSelection];
        
        cellData = self.cellDatas[indexPath.item];
        [cellData updateCellState:YES isOwnSelection:isOwnSelection];
    } else {
        cellData = self.cellDatas[indexPath.item];
        [cellData updateCellState:YES isOwnSelection:isOwnSelection];
    }
    
    if (isOwnSelection) {
        _ownSelectedIndexPath = indexPath;
    } else {
        _otherSelectedIndexPath = indexPath;
    }
    
    [self.delegate didUpdateCellStateWithDoneActivate:[cellData isBothSelected]];
}

- (void)setDeselectedCellAtIndexPath:(NSIndexPath *)indexPath isOwnSelection:(BOOL)isOwnSelection {
    if (!indexPath)
        return;
    
    PhotoFrameData *cellData;

    cellData = self.cellDatas[indexPath.item];
    [cellData updateCellState:NO isOwnSelection:isOwnSelection];
    
    if (isOwnSelection) {
        _ownSelectedIndexPath = nil;
    } else {
        _otherSelectedIndexPath = nil;
    }
    
    [self.delegate didUpdateCellStateWithDoneActivate:NO];
    
}

- (CGSize)sizeOfCell:(CGSize)size {
    CGFloat cellBetweenSpace = 20.0f * 2.0f;
    CGFloat cellWidth = (size.width - cellBetweenSpace) / 3.0f;
    
    return CGSizeMake(cellWidth, cellWidth);
}

- (UIEdgeInsets)edgeInsets:(CGSize)size {
    CGFloat cellBetweenSpace = 20.0f * 2.0f;
    //셀의 높이는 너비와 같다. 셀은 가로로 4개가 배치되므로, 셀 너비값의 4배가 각 셀의 높이를 합한 값이 된다.
    CGFloat cellsHeight = ((size.width - cellBetweenSpace) / 3.0f) * 4.0f;
    //셀 간의 간격은 3곳이 생기며, 라인 간 간격은 20으로 정의되어 있다.
    CGFloat cellsBetweenSpace = 20.0f * 3.0f;
    //남은 공간의 절반을 상단의 inset으로 지정하면, 수직으로 중간에 정렬시킬 수 있다.
    CGFloat topInset = (size.height - cellsHeight - cellsBetweenSpace) / 2.0f;
    
    return UIEdgeInsetsMake(topInset, 0, 0, 0);
}

- (UIImage *)cellImageAtIndexPath:(NSIndexPath *)indexPath {
    return [ImageUtility coloredImageNamed:[ImageUtility photoFrameImageWithIndex:indexPath.item]
                                     color:_cellDatas[indexPath.item].stateColor];
}

- (BOOL)isEqualBothSelectedIndexPath {
    if (!_ownSelectedIndexPath || !_otherSelectedIndexPath) {
        return NO;
    }
    
    if (_ownSelectedIndexPath.item == _otherSelectedIndexPath.item) {
        return YES;
    }
    
    return NO;
}

- (void)setEnableCells:(BOOL)enabled {
    if (enabled) {
        [SessionManager sharedInstance].messageReceiver.photoFrameDataDelegate = self;
    } else {
        [SessionManager sharedInstance].messageReceiver.photoFrameDataDelegate = nil;
    }
    
    for (PhotoFrameData *data in _cellDatas) {
        data.enabled = enabled;
    }
    
    if (self.delegate) {
        [self.delegate didUpdateCellEnabled:enabled];
    }
}


#pragma mark - CollectionViewController DataDelegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return NumberOfPhotoFrameCells;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectPhotoFrameViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SelectPhotoFrameViewCell class]) forIndexPath:indexPath];
    cell.userInteractionEnabled = _cellDatas[indexPath.item].enabled;
    cell.frameImageView.image = [self cellImageAtIndexPath:indexPath];
    
    return cell;
}


#pragma mark - MessageReceiverPhotoFrameDataDelegate Methods

- (void)didReceiveSelectPhotoFrame:(NSIndexPath *)indexPath {
    if (!indexPath)
        return;
    
    [self setSelectedCellAtIndexPath:indexPath isOwnSelection:NO];
}

- (void)didReceiveDeselectPhotoFrame:(NSIndexPath *)indexPath {
    if (!indexPath)
        return;
    
    [self setDeselectedCellAtIndexPath:indexPath isOwnSelection:NO];
}

- (void)didReceiveRequestPhotoFrameConfirm:(NSIndexPath *)indexPath {
    if (!indexPath)
        return;
    
    [self setEnableCells:NO];
    
    //전달받은 사진액자의 인덱스패스와 자신이 선택한 인덱스패스가 다를 경우, 전달받은 사진액자의 인덱스패스로 복원한다.
    if (![self isEqualBothSelectedIndexPath]) {
        [self setSelectedCellAtIndexPath:indexPath isOwnSelection:YES];
    }
    
    if (self.delegate) {
        [self.delegate didReceiveRequestPhotoFrameConfirm:indexPath];
    }
}

- (void)didReceiveReceivePhotoFrameConfirmAck:(BOOL)confirmAck {
    if (self.delegate) {
        [self.delegate didReceivePhotoFrameConfirmAck:confirmAck];
    }
}


#pragma mark - MessagetInterrupterConfirmRequestDelegate Methods

- (void)interruptConfirmRequest {
    if (self.delegate) {
        [self.delegate didInterruptRequestConfirm];
    }
}

@end