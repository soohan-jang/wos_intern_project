//
//  DecorateDataController.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PEDecorate.h"

@protocol PEDecorateControllerDelegate;

@interface PEDecorateMessageSender : NSObject

- (BOOL)sendScreenSizeDeviceDataMessage:(CGSize)screenSize;

- (BOOL)sendSelectDecorateDataMessage:(NSUUID *)uuid;
- (BOOL)sendDeselectDecorateDataMessage:(NSUUID *)uuid;

- (BOOL)sendInsertDecorateDataMessage:(PEDecorate *)insertData;
- (BOOL)sendUpdateDecorateDataMessage:(NSUUID *)uuid updateFrame:(CGRect)updateFrame;
- (BOOL)sendDeleteDecorateDataMessage:(NSUUID *)uuid;

@end

@interface PEDecorateController : NSObject

@property (weak, nonatomic) id<PEDecorateControllerDelegate> delegate;
@property (strong, nonatomic) PEDecorateMessageSender *dataSender;

- (void)addDecorateData:(PEDecorate *)decorateData;
- (void)selectDecorateData:(NSUUID *)uuid selected:(BOOL)selected;
- (void)updateDecorateData:(NSUUID *)uuid frame:(CGRect)frame;
- (void)deleteDecorateData:(NSUUID *)uuid;

@end

@protocol PEDecorateControllerDelegate <NSObject>
@required
- (void)didReceiveScreenSize;
- (void)didUpdateDecorateData:(NSUUID *)uuid;
- (void)didInterruptDecorateDataSelection:(NSUUID *)uuid;

@end