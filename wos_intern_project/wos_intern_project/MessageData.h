//
//  MessageData.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecorateData.h"

typedef NS_ENUM(NSInteger, MessageType) {
    MessageTypeScreenSize          = 0,
    
    MessageTypePhotoFrameSelect,
    MessageTypePhotoFrameDeselect,
    
    MessageTypePhotoFrameRequestConfirm,
    MessageTypePhotoFrameRequestConfirmAck,
    
    MessageTypePhotoDataSelect,
    MessageTypePhotoDataDeselect,
    
    MessageTypePhotoDataInsert,
    MessageTypePhotoDataInsertStart,
    MessageTypePhotoDataInsertFinish,
    
    MessageTypePhotoDataUpdate,
    MessageTypePhotoDataDelete,
    
    MessageTypePhotoDataInsertAck,
    MessageTypePhotoDataUpdateAck,
    
    MessageTypeDecorateDataSelect,
    MessageTypeDecorateDataDeselect,
    
    MessageTypeDecorateDataInsert,
    MessageTypeDecorateDataUpdate,
    MessageTypeDecorateDataDelete
};

@interface MessageData : NSObject

@property (nonatomic, assign) NSInteger messageType;

@property (nonatomic, assign) CGSize screenSize;

@property (nonatomic, strong) NSIndexPath *photoFrameIndexPath;
@property (nonatomic, assign) BOOL photoFrameConfirmAck;

@property (nonatomic, strong) NSIndexPath *photoDataIndexPath;
@property (nonatomic, assign) BOOL photoDataRecevieAck;

@property (nonatomic, strong) NSURL *photoDataOriginalImageURL;
@property (nonatomic, strong) NSURL *photoDataCroppedImageURL;
@property (nonatomic, assign) NSInteger photoDataFilterType;

@property (nonatomic, strong) NSUUID *decorateDataUUID;
@property (nonatomic, strong) DecorateData *decorateData;
@property (nonatomic, assign) CGRect decorateDataFrame;

@end
