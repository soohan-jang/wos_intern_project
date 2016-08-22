//
//  MessageFactory.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 10..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MessageFactory.h"
#import "ConnectionManager.h"

/** VALUE_DATA_TYPE으로 시작되는 값과 매칭되는 키 값 **/
NSString *const kDataType                   = @"data_type";

/** 스크린 크기의 너비와 높이 값에 대한 키 값 **/
/** 너비와 높이가 NSNumber floatValue 값으로 매칭된다 **/
NSString *const kScreenSize                 = @"screen_size";

/** 선택된 사진 액자 인덱스 값에 대한 키 값 **/
/** 인덱스값이 NSIndexPath 값으로 매칭된다 **/
NSString *const kPhotoFrameIndexPath        = @"frame_indexpath";
NSString *const kPhotoFrameConfirmTimestamp = @"frame_confirm_timestamp";

/** 사진 선택 완료 요청에 대한 응답값에 대한 키 값 **/
/** NSNumber boolValue 값으로 매칭된다 **/
NSString *const kPhotoFrameConfirmedAck     = @"frame_confirmed_ack";

/** 사진 입력/삭제, 그림 객체 입력/갱신/삭제에 대한 키 값 **/
NSString *const kPhotoIndexPath             = @"photo_indexpath";

NSString *const kPhotoEditTimestamp         = @"photo_edit_timestamp";
NSString *const kPhotoInsertedDataType      = @"photo_insert_data_type";
NSString *const kPhotoInsertedData          = @"photo_insert_data";
NSString *const kPhotoInsertedAck           = @"photo_insert_ack";

NSString *const kDecorateUUID               = @"decorate_uuid";

NSString *const kDecorateEditTimestamp      = @"decorate_edit_timestamp";
NSString *const kDecorateInsertedData       = @"decorate_insert_data";
NSString *const kDecorateInsertedTimestamp  = @"decorate_insert_timestamp";
NSString *const kDEcorateUpdatedFrame       = @"decorate_update_frame";

@implementation MessageFactory

+ (NSDictionary *)messageGenerateScreenSize:(CGSize)screenSize {
    if (CGSizeEqualToSize(screenSize, CGSizeZero))
        return nil;
    
    NSDictionary *message = @{kDataType: @(vDataTypeScreenSize),
                              kScreenSize: [NSValue valueWithCGSize:screenSize]};
    
    return message;
}

+ (NSDictionary *)messageGeneratePhotoFrameSelected:(NSIndexPath *)selectedIndexPath {
    if (!selectedIndexPath) {
        return nil;
    }

    NSDictionary *message =  @{kDataType: @(vDataTypePhotoFrameSelected),
                                        kPhotoFrameIndexPath: selectedIndexPath};
    
    return message;
}

+ (NSDictionary *)messageGeneratePhotoFrameRequestConfirm:(NSIndexPath *)selectedIndexPath {
    if (selectedIndexPath == nil) {
        return nil;
    }
    
    NSDictionary *message = @{kDataType: @(vDataTypePhotoFrameRequestConfirm),
                              kPhotoFrameIndexPath: selectedIndexPath,
                              kPhotoFrameConfirmTimestamp: @([[NSDate date] timeIntervalSince1970] * 1000)};
    
    return message;
}

+ (NSDictionary *)messageGeneratePhotoFrameConfirmed:(BOOL)confirm {
    NSDictionary *message = @{kDataType: @(vDataTypePhotoFrameConfirmedAck),
                              kPhotoFrameConfirmedAck: @(confirm)};
    
    return message;
                              
}

+ (NSDictionary *)messageGeneratePhotoEdit:(NSIndexPath *)editIndexPath {
    if (editIndexPath == nil) {
        return nil;
    }
    
    NSDictionary *message = @{kDataType: @(vDataTypePhotoEdit),
                              kPhotoIndexPath: editIndexPath,
                              kPhotoEditTimestamp: @([[NSDate date] timeIntervalSince1970] * 1000)};
    
    return message;
}

+ (NSDictionary *)messageGeneratePhotoEditCanceled:(NSIndexPath *)editIndexPath {
    if (editIndexPath == nil) {
        return nil;
    }
    
    NSDictionary *message = @{kDataType: @(vDataTypePhotoEditCanceled),
                              kPhotoIndexPath: editIndexPath};
    
    return message;
}

+ (NSDictionary *)messageGeneratePhotoInsertCompleted:(NSIndexPath *)insertIndexPath success:(BOOL)success {
    NSDictionary *message = @{kDataType: @(vDataTypePhotoInsertedAck),
                              kPhotoIndexPath: insertIndexPath,
                              kPhotoInsertedAck: @(success)};
    
    return message;
}

+ (NSDictionary *)messageGeneratePhotoDeleted:(NSIndexPath *)deleteIndexPath {
    if (deleteIndexPath == nil) {
        return nil;
    }
    
    NSDictionary *message = @{kDataType: @(vDataTypePhotoDeleted),
                              kPhotoIndexPath:deleteIndexPath};
    
    return message;
}

+ (NSDictionary *)messageGenerateDecorateDataEdit:(NSUUID *)uuid {
    NSDictionary *message = @{kDataType: @(vDataTypeDecorateEdit),
                              kDecorateUUID: uuid,
                              kDecorateEditTimestamp: @([[NSDate date] timeIntervalSince1970] * 1000)};
    
    return message;
}

+ (NSDictionary *)messageGenerateDecorateDataEditCanceled:(NSUUID *)uuid {
    NSDictionary *message = @{kDataType: @(vDataTypeDecorateEditCanceled),
                            kDecorateUUID: uuid};
    
    return message;
}

+ (NSDictionary *)messageGenerateDecorateDataInserted:(DecorateData *)data {
    if (!data) {
        return nil;
    }
    
    NSDictionary *message = @{kDataType: @(vDataTypeDecorateInserted),
                              kDecorateInsertedData:data};
    
    return message;
}

+ (NSDictionary *)messageGenerateDecorateDataUpdated:(NSUUID *)uuid frame:(CGRect)frame {
    if (CGRectIsEmpty(frame)) {
        return nil;
    }
    
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    frame = CGRectMake(frame.origin.x * connectionManager.widthRatio,
                       frame.origin.y * connectionManager.heightRatio,
                       frame.size.width * connectionManager.widthRatio,
                       frame.size.height * connectionManager.heightRatio);
    
    NSDictionary *message = @{kDataType: @(vDataTypeDecorateUpdated),
                              kDecorateUUID: uuid,
                              kDEcorateUpdatedFrame: [NSValue valueWithCGRect:frame]};
    
    return message;
}

+ (NSDictionary *)messageGenerateDecorateDataMoved:(NSUUID *)uuid movedRect:(CGRect)movedRect {
    if (CGRectIsEmpty(movedRect)) {
        return nil;
    }
    
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    CGRect moveRect = CGRectMake(movedRect.origin.x * connectionManager.widthRatio,
                                 movedRect.origin.y * connectionManager.heightRatio,
                                 movedRect.size.width,
                                 movedRect.size.height);
    
    NSDictionary *message = @{kDataType: @(vDataTypeDecorateUpdated),
                              kDecorateUUID: uuid,
                              kDEcorateUpdatedFrame: [NSValue valueWithCGRect:moveRect]};
    
    return message;
}

+ (NSDictionary *)messageGenerateDecorateDataResized:(NSUUID *)uuid resizedRect:(CGRect)resizedRect {
    if (CGRectIsEmpty(resizedRect)) {
        return nil;
    }
    
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    resizedRect = CGRectMake(resizedRect.origin.x,
                             resizedRect.origin.y * connectionManager.heightRatio,
                             resizedRect.size.width * connectionManager.widthRatio,
                             resizedRect.size.height * connectionManager.heightRatio);
    
    NSDictionary *message = @{kDataType: @(vDataTypeDecorateUpdated),
                              kDecorateUUID: uuid,
                              kDEcorateUpdatedFrame: [NSValue valueWithCGRect:resizedRect]};
    
    return message;
}

+ (NSDictionary *)messageGenerateDecorateDataDeleted:(NSUUID *)uuid {
    NSDictionary *message = @{kDataType: @(vDataTypeDecorateDeleted),
                              kDecorateUUID: uuid};
    
    return message;
}

@end
