//
//  MessageReceiver.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PESession.h"
#import "DecorateData.h"

@protocol MessageReceiverStateChangeDelegate;
@protocol MessageReceiverPhotoFrameDataDelegate;
@protocol MessageReceiverDeviceDataDelegate;
@protocol MessageReceiverPhotoDataDelegate;
@protocol MessageReceiverDecorateDataDelegate;

@interface MessageReceiver : NSObject

@property (nonatomic, weak) id<MessageReceiverStateChangeDelegate>     stateChangeDelegate;
@property (nonatomic, weak) id<MessageReceiverPhotoFrameDataDelegate>  photoFrameDataDelegate;
@property (nonatomic, weak) id<MessageReceiverDeviceDataDelegate>      deviceDataDelegate;
@property (nonatomic, weak) id<MessageReceiverPhotoDataDelegate>       photoDataDelegate;
@property (nonatomic, weak) id<MessageReceiverDecorateDataDelegate>    decorateDataDelegate;

- (instancetype)initWithSession:(PESession *)session;

@end

@protocol MessageReceiverStateChangeDelegate <NSObject>
@required
- (void)didReceiveChangeSessionState:(NSInteger)state;

@end

@protocol MessageReceiverPhotoFrameDataDelegate <NSObject>
@required
- (void)didReceiveSelectPhotoFrame:(NSIndexPath *)indexPath;
- (void)didReceiveDeselectPhotoFrame:(NSIndexPath *)indexPath;

- (void)didReceiveRequestPhotoFrameConfirm:(NSIndexPath *)indexPath;
- (void)didReceiveReceivePhotoFrameConfirmAck:(BOOL)confirmAck;

@end

@protocol MessageReceiverDeviceDataDelegate <NSObject>
@required
- (void)didReceiveDeviceScreenSize:(CGSize)screenSize;

@end

@protocol MessageReceiverPhotoDataDelegate <NSObject>
@required
- (void)didReceiveSelectPhotoData:(NSIndexPath *)indexPath;
- (void)didReceiveDeselectPhotoData:(NSIndexPath *)indexPath;

- (void)didReceiveStartReceivePhotoData:(NSIndexPath *)indexPath;
- (void)didReceiveFinishReceivePhotoData:(NSIndexPath *)indexPath;
- (void)didReceiveErrorReceivePhotoData:(NSIndexPath *)indexPath dataType:(NSString *)dataType;

- (void)didReceiveInsertPhotoData:(NSIndexPath *)indexPath dataType:(NSString *)dataType insertDataURL:(NSURL *)insertDataURL filterType:(NSInteger)filterType;
- (void)didReceiveUpdatePhotoData:(NSIndexPath *)indexPath updateDataURL:(NSURL *)updateDataURL filterType:(NSInteger)filterType;
- (void)didReceiveDeletePhotoData:(NSIndexPath *)indexPath;

- (void)didReceivePhotoDataAck:(NSIndexPath *)indexPath ack:(BOOL)ack;

@end

@protocol MessageReceiverDecorateDataDelegate <NSObject>
@required
- (void)didReceiveSelectDecorateData:(NSUUID *)uuid;
- (void)didReceiveDeselectDecorateData:(NSUUID *)uuid;

- (void)didReceiveInsertDecorateData:(DecorateData *)insertData;
- (void)didReceiveUpdateDecorateData:(NSUUID *)uuid updateFrame:(CGRect)updateFrame;
- (void)didReceiveDeleteDecorateData:(NSUUID *)uuid;

@end