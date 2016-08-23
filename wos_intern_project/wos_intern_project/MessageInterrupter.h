//
//  MessageInterrupter.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 23..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageInterrupterConfirmRequestDelegate;
@protocol MessageInterrupterPhotoDataSelectionDelegate;
@protocol MessageInterrupterDecorateDataSelectionDelegate;

@interface MessageInterrupter : NSObject

@property (weak, nonatomic) id<MessageInterrupterConfirmRequestDelegate> interruptConfirmRequestDelegate;
@property (weak, nonatomic) id<MessageInterrupterPhotoDataSelectionDelegate>  interruptPhotoDataSelectionDelegate;
@property (weak, nonatomic) id<MessageInterrupterDecorateDataSelectionDelegate>  interruptDecorateDataSelectionDelegate;

+ (instancetype)sharedInstance;

- (void)setSentTimestamp:(NSTimeInterval)timestamp;
- (void)setSentTimestamp:(NSTimeInterval)timestamp indexPath:(NSIndexPath *)indexPath;
- (void)setSentTimestamp:(NSTimeInterval)timestamp uuid:(NSUUID *)uuid;

- (void)setReceivedTimestamp:(NSTimeInterval)timestamp;
- (void)setReceivedTimestamp:(NSTimeInterval)timestamp indexPath:(NSIndexPath *)indexPath;
- (void)setReceivedTimestamp:(NSTimeInterval)timestamp uuid:(NSUUID *)uuid;

@end

@protocol MessageInterrupterConfirmRequestDelegate <NSObject>
@required
- (void)interruptConfirmRequest;

@end

@protocol MessageInterrupterPhotoDataSelectionDelegate <NSObject>
@required
- (void)interruptPhotoDataSelction:(NSIndexPath *)indexPath;

@end

@protocol MessageInterrupterDecorateDataSelectionDelegate <NSObject>
@required
- (void)interruptDecorateDataSelection:(NSUUID *)uuid;

@end