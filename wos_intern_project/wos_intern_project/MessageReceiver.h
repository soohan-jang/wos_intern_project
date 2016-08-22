//
//  MessageReceiver.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 17..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeneralSession.h"
#import "DecorateData.h"

@protocol StateChangeDelegate;
@protocol PhotoFrameDataDelegate;
@protocol PhotoDataDelegate;
@protocol DecorateDataDelegate;

@interface MessageReceiver : NSObject

@property (nonatomic, weak) id<StateChangeDelegate>     stateChangeDelegate;
@property (nonatomic, weak) id<PhotoFrameDataDelegate>  photoFrameDataDelegate;
@property (nonatomic, weak) id<PhotoDataDelegate>       photoDataDelegate;
@property (nonatomic, weak) id<DecorateDataDelegate>    decorateDataDelegate;

- (instancetype)initWithSession:(GeneralSession *)session;

@end

@protocol StateChangeDelegate <NSObject>
@required
- (void)didReceiveChangeAvailiableState:(NSInteger)state;
- (void)didReceiveChangeSessionState:(NSInteger)state;

@end

@protocol PhotoFrameDataDelegate <NSObject>
@required
- (void)didReceiveScreenSize:(CGSize)screenSize;

- (void)didReceiveSelectPhotoFrame:(NSIndexPath *)indexPath;
- (void)didReceiveDeselectPhotoFrame:(NSIndexPath *)indexPath;

- (void)didReceiveRequestPhotoFrameConfirm:(NSIndexPath *)indexPath;
- (void)didReceiveReceivePhotoFrameConfirmAck:(BOOL)confirmAck;

- (void)didReceiveRequestInterruptPhotoFrameConfirm;

@end

@protocol PhotoDataDelegate <NSObject>
@required
- (void)didReceiveSelectPhotoData:(NSIndexPath *)indexPath;
- (void)didReceiveDeselectPhotoData:(NSIndexPath *)indexPath;

- (void)didReceiveStartInsertPhotoData:(NSIndexPath *)indexPath;
- (void)didReceiveFinishInsertPhotoData:(NSIndexPath *)indexPath;

- (void)didReceiveInsertPhotoData:(NSIndexPath *)indexPath insertDataURL:(NSURL *)insertDataURL filterType:(NSInteger)filterType;
- (void)didReceiveUpdatePhotoData:(NSIndexPath *)indexPath updateDataURL:(NSURL *)updateDataURL filterType:(NSInteger)filterType;
- (void)didReceiveDeletePhotoData:(NSIndexPath *)indexPath;

- (void)didReceiveInsertPhotoDataAck:(NSIndexPath *)indexPath;
- (void)didReceiveUpdatePhotoDataAck:(NSIndexPath *)indexPath;

- (void)didReceiveSelectInterruptPhotoData:(NSIndexPath *)indexPath;

@end

@protocol DecorateDataDelegate <NSObject>
@required
- (void)didReceiveSelectDecorateData:(NSUUID *)uuid;
- (void)didReceiveDeselectDecorateData:(NSUUID *)uuid;

- (void)didReceiveInsertDecorateData:(DecorateData *)insertData;
- (void)didReceiveUpdateDecorateData:(NSUUID *)uuid updateFrame:(CGRect)updateFrame;
- (void)didReceiveDeleteDecorateData:(NSUUID *)uuid;

- (void)didReceiveSelectInterruptDecorateData:(NSUUID *)uuid;

@end