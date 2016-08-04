//
//  ConnectionManagerConstants.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 3..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/NSString.h>

/** MCSession Service Type **/
/** 이 값이 일치하는 장비만 Bluetooth 장비목록에 노출된다 **/
extern NSString *const ApplicationBluetoothServiceType;

/** VALUE_DATA_TYPE으로 시작되는 값과 매칭되는 키 값 **/
extern NSString *const kDataType;

typedef NS_ENUM(NSInteger, ValueDataType) {
    vDataTypeScreenSize                   = 100,
    
    vDataTypePhotoFrameSelected           = 200,
    vDataTypePhotoFrameConfirm            = 201,
    vDataTypePhotoFrameConfirmAck         = 202,
    vDataTypePhotoFrameDisconnected       = 203,
    
    vDataTypeEditorPhotoInsertAck         = 301,
    vDataTypeEditorPhotoEdit              = 302,
    vDataTypeEditorPhotoEditCancel        = 303,
    vDataTypeEditorPhotoDelete            = 304,
    
    vDataTypeEditorDrawingEdit            = 305,
    vDataTypeEditorDrawingEditCancel      = 306,
    vDataTypeEditorDrawingInsert          = 307,
    vDataTypeEditorDrawingUpdateMoved     = 308,
    vDataTypeEditorDrawingUpdateResized   = 309,
    vDataTypeEditorDrawingUpdateRotated   = 310,
    vDataTypeEditorDrawingUpdateZOrder    = 311,
    vDataTypeEditorDrawingDelete          = 312,
    vDataTypeEditorDisconnected           = 313
};

/** 스크린 크기의 너비와 높이 값에 대한 키 값 **/
/** 너비와 높이가 NSNumber floatValue 값으로 매칭된다 **/
extern NSString *const kScreenWidth;
extern NSString *const kScreenHeight;

/** 선택된 사진 액자 인덱스 값에 대한 키 값 **/
/** 인덱스값이 NSIndexPath 값으로 매칭된다 **/
extern NSString *const kPhotoFrameSelected;
/** 사진 선택 완료 요청에 대한 응답값에 대한 키 값 **/
/** NSNumber boolValue 값으로 매칭된다 **/
extern NSString *const kPhotoFrameSelectedConfirmAck;

/** 사진 입력/삭제, 그림 객체 입력/갱신/삭제에 대한 키 값 **/
/** 아직 미정. 근데 아마 사진은 byte[], 그림 객체는 DrawingObject 값으로 매칭될 듯 **/
extern NSString *const kEditorPhotoInsertIndex;
extern NSString *const kEditorPhotoInsertDataType;
extern NSString *const kEditorPhotoInsertData;
extern NSString *const kEditorPhotoInsertAck;
extern NSString *const kEditorPhotoEditIndex;
extern NSString *const kEditorPhotoDeleteIndex;

extern NSString *const kEditorDrawingEditID;
extern NSString *const kEditorDrawingInsertData;
extern NSString *const kEditorDrawingInsertTimestamp;
extern NSString *const kEditorDrawingUpdateID;
//extern NSString *const kEditorDrawingUpdateData;
extern NSString *const kEditorDrawingUpdateMovedX;
extern NSString *const kEditorDrawingUpdateMovedY;
extern NSString *const kEditorDrawingUpdateResizedWidth;
extern NSString *const kEditorDrawingUpdateResizedHeight;
extern NSString *const kEditorDrawingUpdateRotatedAngle;
//extern NSString *const kEditorDrawingUpdateZOrder;
extern NSString *const kEditorDrawingDeleteID;