//
//  MessageReceiver.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PESession.h"
#import "PEMessageBuffer.h"

#import "PEMessage.h"
#import "PEDecorate.h"

@protocol PEMessageReceiverStateChangeDelegate;
@protocol PEMessageReceiverSyncTimestampDelegate;
@protocol PEMessageReceiverPhotoFrameDataDelegate;
@protocol PEMessageReceiverDeviceDataDelegate;
@protocol PEMessageReceiverPhotoDataDelegate;
@protocol PEMessageReceiverDecorateDataDelegate;

@interface PEMessageReceiver : NSObject

@property (nonatomic, weak) id<PEMessageReceiverStateChangeDelegate>     stateChangeDelegate;
@property (nonatomic, weak) id<PEMessageReceiverSyncTimestampDelegate>   syncTimestampDelegate;
@property (nonatomic, weak) id<PEMessageReceiverPhotoFrameDataDelegate>  photoFrameDataDelegate;
@property (nonatomic, weak) id<PEMessageReceiverDeviceDataDelegate>      deviceDataDelegate;
@property (nonatomic, weak) id<PEMessageReceiverPhotoDataDelegate>       photoDataDelegate;
@property (nonatomic, weak) id<PEMessageReceiverDecorateDataDelegate>    decorateDataDelegate;

- (instancetype)initWithSession:(PESession *)session;
- (void)setMessageBufferEnabled:(BOOL)enabled;
- (void)startSynchronizeMessage;

@end

@protocol PEMessageReceiverStateChangeDelegate <NSObject>
@required
- (void)didReceiveChangeSessionState:(NSInteger)state;

@end

@protocol PEMessageReceiverSyncTimestampDelegate <NSObject>
@required
- (void)didReceiveStandardTimestamp:(NSTimeInterval)timestamp;

@end

@protocol PEMessageReceiverPhotoFrameDataDelegate <NSObject>
@required
- (void)didReceiveSelectPhotoFrame:(NSIndexPath *)indexPath;
- (void)didReceiveDeselectPhotoFrame:(NSIndexPath *)indexPath;

- (void)didReceiveRequestPhotoFrameConfirm:(NSIndexPath *)indexPath;
- (void)didReceiveRequestPhotoFrameConfirmAck:(BOOL)confirmAck;

@end

@protocol PEMessageReceiverDeviceDataDelegate <NSObject>
@required
- (void)didReceiveDeviceScreenSize:(CGSize)screenSize;

@end

@protocol PEMessageReceiverPhotoDataDelegate <NSObject>
@required
- (void)didReceiveSelectPhotoData:(NSIndexPath *)indexPath;
- (void)didReceiveDeselectPhotoData:(NSIndexPath *)indexPath;

- (void)didReceiveStartInsertPhotoData:(NSIndexPath *)indexPath;
- (void)didReceiveFinishInsertPhotoData:(NSIndexPath *)indexPath;
- (void)didReceiveErrorInsertPhotoData:(NSIndexPath *)indexPath;

- (void)didReceiveInsertPhotoData:(NSIndexPath *)indexPath dataType:(NSString *)dataType insertDataURL:(NSURL *)insertDataURL filterType:(NSInteger)filterType;
- (void)didReceiveUpdatePhotoData:(NSIndexPath *)indexPath updateDataURL:(NSURL *)updateDataURL filterType:(NSInteger)filterType;
- (void)didReceiveDeletePhotoData:(NSIndexPath *)indexPath;

- (void)didReceivePhotoDataAck:(NSIndexPath *)indexPath ack:(BOOL)ack;

@end

@protocol PEMessageReceiverDecorateDataDelegate <NSObject>
@required
- (void)didReceiveSelectDecorateData:(NSUUID *)uuid;
- (void)didReceiveDeselectDecorateData:(NSUUID *)uuid;

- (void)didReceiveInsertDecorateData:(PEDecorate *)insertData;
- (void)didReceiveUpdateDecorateData:(NSUUID *)uuid updateFrame:(CGRect)updateFrame;
- (void)didReceiveDeleteDecorateData:(NSUUID *)uuid;

@end