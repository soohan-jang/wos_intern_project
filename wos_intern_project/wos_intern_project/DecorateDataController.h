//
//  DecorateDataController.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecorateData.h"

@protocol DecorateDataControllerDelegate;

@interface DecorateDataSender : NSObject

- (BOOL)sendScreenSizeDeviceDataMessage:(CGSize)screenSize;

- (BOOL)sendSelectDecorateDataMessage:(NSUUID *)uuid;
- (BOOL)sendDeselectDecorateDataMessage:(NSUUID *)uuid;

- (BOOL)sendInsertDecorateDataMessage:(DecorateData *)insertData;
- (BOOL)sendUpdateDecorateDataMessage:(NSUUID *)uuid updateFrame:(CGRect)updateFrame;
- (BOOL)sendDeleteDecorateDataMessage:(NSUUID *)uuid;

@end

@interface DecorateDataController : NSObject

@property (weak, nonatomic) id<DecorateDataControllerDelegate> delegate;
@property (strong, nonatomic) DecorateDataSender *dataSender;

- (void)addDecorateData:(DecorateData *)decorateData;
- (void)selectDecorateData:(NSUUID *)uuid selected:(BOOL)selected;
- (void)updateDecorateData:(NSUUID *)uuid frame:(CGRect)frame;
- (void)deleteDecorateData:(NSUUID *)uuid;

@end

@protocol DecorateDataControllerDelegate <NSObject>
@required
- (void)didReceiveScreenSize;
- (void)didUpdateDecorateData:(NSUUID *)uuid;
- (void)didInterruptDecorateDataSelection:(NSUUID *)uuid;

@end