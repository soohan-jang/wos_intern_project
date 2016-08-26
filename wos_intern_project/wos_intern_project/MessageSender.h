//
//  MessageSender.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PESession.h"
#import "PEDecorate.h"

@interface MessageSender : NSObject

- (instancetype)initWithSession:(PESession *)session;

- (BOOL)sendSelectPhotoFrameMessage:(NSIndexPath *)indexPath;
- (BOOL)sendDeselectPhotoFrameMessage:(NSIndexPath *)indexPath;

- (BOOL)sendPhotoFrameConfrimRequestMessage:(NSIndexPath *)indexPath;
- (BOOL)sendPhotoFrameConfirmAckMessage:(BOOL)confrimAck;

- (BOOL)sendScreenSizeDeviceDataMessage:(CGSize)screenSize;

- (BOOL)sendSelectPhotoDataMessage:(NSIndexPath *)indexPath;
- (BOOL)sendDeselectPhotoDataMessage:(NSIndexPath *)indexPath;

- (void)sendInsertPhotoDataMessage:(NSIndexPath *)indexPath originalImageURL:(NSURL *)originalImageURL croppedImageURL:(NSURL *)croppedImageURL filterType:(NSInteger)filterType;
- (void)sendUpdatePhotoDataMessage:(NSIndexPath *)indexPath croppedImageURL:(NSURL *)croppedImageURL filterType:(NSInteger)filterType;
- (BOOL)sendDeletePhotoDataMessage:(NSIndexPath *)indexPath;

- (BOOL)sendPhotoDataAckMessage:(NSIndexPath *)indexPath ack:(BOOL)ack;

- (BOOL)sendSelectDecorateDataMessage:(NSUUID *)uuid;
- (BOOL)sendDeselectDecorateDataMessage:(NSUUID *)uuid;

- (BOOL)sendInsertDecorateDataMessage:(PEDecorate *)insertData;
- (BOOL)sendUpdateDecorateDataMessage:(NSUUID *)uuid updateFrame:(CGRect)updateFrame;
- (BOOL)sendDeleteDecorateDataMessage:(NSUUID *)uuid;

@end
