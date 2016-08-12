//
//  MessageFactory.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 10..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIView.h>

/** VALUE_DATA_TYPE으로 시작되는 값과 매칭되는 키 값 **/
extern NSString *const kDataType;

typedef NS_ENUM(NSInteger, ValueDataType) {
    vDataTypeScreenSize                   = 100,
    
    vDataTypePhotoFrameSelected           = 200,
    vDataTypePhotoFrameRequestConfirm     = 201,
    vDataTypePhotoFrameConfirmedAck       = 202,
    
    vDataTypeEditorPhotoEdit              = 300,
    vDataTypeEditorPhotoEditCanceled      = 301,
    vDataTypeEditorPhotoInsertedAck       = 302,
    vDataTypeEditorPhotoDeleted           = 303,
    
    vDataTypeEditorDecorateEdit           = 400,
    vDataTypeEditorDecorateEditCanceled   = 401,
    vDataTypeEditorDecorateInserted       = 402,
    vDataTypeEditorDecorateUpdateMoved    = 403,
    vDataTypeEditorDecorateUpdateResized  = 404,
    vDataTypeEditorDecorateUpdateRotated  = 405,
    vDataTypeEditorDecorateUpdateZOrder   = 406,
    vDataTypeEditorDecorateDeleted        = 407
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
extern NSString *const kEditorPhotoIndexPath;

extern NSString *const kEditorPhotoEditTimestamp;
extern NSString *const kEditorPhotoInsertedDataType;
extern NSString *const kEditorPhotoInsertedData;
extern NSString *const kEditorPhotoInsertedAck;

extern NSString *const kEditorDecorateIndex;

extern NSString *const kEditorDecorateEditTimestamp;
extern NSString *const kEditorDecorateInsertedData;
extern NSString *const kEditorDecorateInsertedTimestamp;
extern NSString *const kEditorDecorateUpdateMovedPoint;
extern NSString *const kEditorDecorateUpdateResizedRect;
extern NSString *const kEditorDecorateUpdateRotatedAngle;
extern NSString *const kEditorDecorateUpdateZOrder;
extern NSString *const kEditorDecorateDeleteTimestamp;

@interface MessageFactory : NSObject

+ (NSDictionary *)MessageGenerateScreenSize:(CGSize)screenSize;

+ (NSDictionary *)MessageGeneratePhotoFrameSelected:(NSIndexPath *)selectedIndexPath;
+ (NSDictionary *)MessageGeneratePhotoFrameRequestConfirm:(NSIndexPath *)selectedIndexPath;
+ (NSDictionary *)MessageGeneratePhotoFrameConfirmed:(BOOL)confirm;

+ (NSDictionary *)MessageGeneratePhotoEdit:(NSIndexPath *)editIndexPath;
+ (NSDictionary *)MessageGeneratePhotoEditCanceled:(NSIndexPath *)editIndexPath;
+ (NSDictionary *)MessageGeneratePhotoInsertCompleted:(NSIndexPath *)insertIndexPathItem success:(BOOL)success;
+ (NSDictionary *)MessageGeneratePhotoDeleted:(NSIndexPath *)deleteIndexPath;

+ (NSDictionary *)MessageGenerateDecorateDataEdit:(NSInteger)index;
+ (NSDictionary *)MessageGenerateDecorateDataEditCanceled:(NSInteger)index;
+ (NSDictionary *)MessageGenerateDecorateDataInserted:(UIImage *)data timestamp:(NSNumber *)timestamp;
+ (NSDictionary *)MessageGenerateDecorateDataMoved:(NSInteger)index movedPoint:(CGPoint)movedPoint;
+ (NSDictionary *)MessageGenerateDecorateDataResized:(NSInteger)index resizedRect:(CGRect)resizedRect;
+ (NSDictionary *)MessageGenerateDecorateDataRotated:(NSInteger)index rotatedAngle:(CGFloat)rotatedAngle;
+ (NSDictionary *)MessageGenerateDecorateDataChangZOrder:(NSInteger)index;
+ (NSDictionary *)MessageGenerateDecorateDataDeleted:(NSNumber *)timestamp;

@end
