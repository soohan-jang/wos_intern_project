//
//  MessageFactory.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 10..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIView.h>
#import "DecorateData.h"

/** VALUE_DATA_TYPE으로 시작되는 값과 매칭되는 키 값 **/
extern NSString *const kDataType;

typedef NS_ENUM(NSInteger, ValueDataType) {
    vDataTypeScreenSize               = 100,
    
    vDataTypePhotoFrameSelected       = 200,
    vDataTypePhotoFrameRequestConfirm = 201,
    vDataTypePhotoFrameConfirmedAck   = 202,
    
    vDataTypePhotoEdit                = 300,
    vDataTypePhotoEditCanceled        = 301,
    vDataTypePhotoInsertedAck         = 302,
    vDataTypePhotoDeleted             = 303,
    
    vDataTypeDecorateEdit             = 400,
    vDataTypeDecorateEditCanceled     = 401,
    vDataTypeDecorateInserted         = 402,
    vDataTypeDecorateUpdated          = 403,
    vDataTypeDecorateDeleted          = 404
};

/** 스크린 크기의 너비와 높이 값에 대한 키 값 **/
/** 너비와 높이가 NSNumber floatValue 값으로 매칭된다 **/
extern NSString *const kScreenSize;

/** 선택된 사진 액자 인덱스 값에 대한 키 값 **/
/** 인덱스값이 NSIndexPath 값으로 매칭된다 **/
extern NSString *const kPhotoFrameIndexPath;
extern NSString *const kPhotoFrameConfirmTimestamp;

/** 사진 선택 완료 요청에 대한 응답값에 대한 키 값 **/
/** NSNumber boolValue 값으로 매칭된다 **/
extern NSString *const kPhotoFrameConfirmedAck;

/** 사진 입력/삭제, 그림 객체 입력/갱신/삭제에 대한 키 값 **/
extern NSString *const kPhotoIndexPath;

extern NSString *const kPhotoEditTimestamp;
extern NSString *const kPhotoInsertedDataType;
extern NSString *const kPhotoInsertedData;
extern NSString *const kPhotoInsertedAck;

extern NSString *const kDecorateUUID;

extern NSString *const kDecorateEditTimestamp;
extern NSString *const kDecorateInsertedData;
extern NSString *const kDEcorateUpdatedFrame;

@interface MessageFactory : NSObject

+ (NSDictionary *)messageGenerateScreenSize:(CGSize)screenSize;

+ (NSDictionary *)messageGeneratePhotoFrameSelected:(NSIndexPath *)selectedIndexPath;
+ (NSDictionary *)messageGeneratePhotoFrameRequestConfirm:(NSIndexPath *)selectedIndexPath;
+ (NSDictionary *)messageGeneratePhotoFrameConfirmed:(BOOL)confirm;

+ (NSDictionary *)messageGeneratePhotoEdit:(NSIndexPath *)editIndexPath;
+ (NSDictionary *)messageGeneratePhotoEditCanceled:(NSIndexPath *)editIndexPath;
+ (NSDictionary *)messageGeneratePhotoInsertCompleted:(NSIndexPath *)insertIndexPathItem success:(BOOL)success;
+ (NSDictionary *)messageGeneratePhotoDeleted:(NSIndexPath *)deleteIndexPath;

+ (NSDictionary *)messageGenerateDecorateDataEdit:(NSUUID *)uuid;
+ (NSDictionary *)messageGenerateDecorateDataEditCanceled:(NSUUID *)uuid;
+ (NSDictionary *)messageGenerateDecorateDataInserted:(DecorateData *)data;
+ (NSDictionary *)messageGenerateDecorateDataUpdated:(NSUUID *)uuid frame:(CGRect)frame;
//+ (NSDictionary *)messageGenerateDecorateDataMoved:(NSUUID *)uuid movedRect:(CGRect)movedRect;
//+ (NSDictionary *)messageGenerateDecorateDataResized:(NSUUID *)uuid resizedRect:(CGRect)resizedRect;
+ (NSDictionary *)messageGenerateDecorateDataDeleted:(NSUUID *)uuid;

@end
