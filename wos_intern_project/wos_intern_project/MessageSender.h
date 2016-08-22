//
//  MessageSender.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "GeneralSession.h"
#import "DecorateData.h"

@interface MessageSender : NSObject

- (instancetype)initWithSession:(GeneralSession *)session;

- (BOOL)sendScreenSizeMessage:(CGSize)screenSize;

- (BOOL)sendSelectPhotoFrameMessage:(NSIndexPath *)indexPath;
- (BOOL)sendDeselectPhotoFrameMessage:(NSIndexPath *)indexPath;

- (BOOL)sendPhotoFrameConfrimRequestMessage:(NSIndexPath *)indexPath;
- (BOOL)sendPhotoframeConfirmAckMessage:(BOOL)confrimAck;

- (BOOL)sendSelectPhotoDataMessage:(NSIndexPath *)indexPath;
- (BOOL)sendDeselectPhotoDataMessage:(NSIndexPath *)indexPath;

- (void)sendInsertPhotoDataMessage:(NSIndexPath *)indexPath originalImageURL:(NSURL *)originalImageURL croppedImageURL:(NSURL *)croppedImageURL filterType:(NSInteger)filterType;
- (void)sendUpdatePhotoDataMessage:(NSIndexPath *)indexPath croppedImageURL:(NSURL *)croppedImageURL filterType:(NSInteger)filterType;
- (BOOL)sendDeletePhotoDataMessage:(NSIndexPath *)indexPath;

- (BOOL)sendInsertPhotoDataAckMessage:(NSIndexPath *)indexPath insertAck:(BOOL)insertAck;
- (BOOL)sendUpdatePhotoDataAckMessage:(NSIndexPath *)indexPath updateAck:(BOOL)updateAck;

- (BOOL)sendSelectDecorateDataMessage:(NSUUID *)uuid;
- (BOOL)sendDeselectDecorateDataMessage:(NSUUID *)uuid;

- (BOOL)sendInsertDecorateDataMessage:(DecorateData *)insertData;
- (BOOL)sendUpdateDecorateDataMessage:(NSUUID *)uuid updateFrame:(CGRect)updateFrame;
- (BOOL)sendDeleteDecorateDataMessage:(NSUUID *)uuid;

@end
