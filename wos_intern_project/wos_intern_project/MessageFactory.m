//
//  MessageFactory.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 10..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MessageFactory.h"

/** VALUE_DATA_TYPE으로 시작되는 값과 매칭되는 키 값 **/
NSString *const kDataType                              = @"data_type";

/** 스크린 크기의 너비와 높이 값에 대한 키 값 **/
/** 너비와 높이가 NSNumber floatValue 값으로 매칭된다 **/
NSString *const kScreenSize                            = @"screen_size";

/** 선택된 사진 액자 인덱스 값에 대한 키 값 **/
/** 인덱스값이 NSIndexPath 값으로 매칭된다 **/
NSString *const kPhotoFrameIndex                       = @"photo_frame_index";
NSString *const kPhotoFrameConfirmTimestamp            = @"photo_frame_confirm_timestamp";

/** 사진 선택 완료 요청에 대한 응답값에 대한 키 값 **/
/** NSNumber boolValue 값으로 매칭된다 **/
NSString *const kPhotoFrameConfirmedAck                = @"photo_frame_confirmed_ack";

/** 사진 입력/삭제, 그림 객체 입력/갱신/삭제에 대한 키 값 **/
NSString *const kEditorPhotoIndexPath                  = @"photo_indexpath";

NSString *const kEditorPhotoEditTimestamp              = @"photo_edit_timestamp";
NSString *const kEditorPhotoInsertedDataType           = @"photo_insert_data_type";
NSString *const kEditorPhotoInsertedData               = @"photo_insert_data";
NSString *const kEditorPhotoInsertedAck                = @"photo_insert_ack";

NSString *const kEditorDecorateIndex                   = @"decorate_index";

NSString *const kEditorDecorateEditTimestamp           = @"decorate_edit_timestamp";
NSString *const kEditorDecorateInsertedData            = @"decorate_insert_data";
NSString *const kEditorDecorateInsertedTimestamp       = @"decorate_insert_timestamp";
NSString *const kEditorDecorateUpdateMovedPoint        = @"decorate_update_moved_point";
NSString *const kEditorDecorateUpdateResizedRect       = @"decorate_update_resized_rect";
NSString *const kEditorDecorateUpdateRotatedAngle      = @"decorate_update_rotated_angle";
NSString *const kEditorDecorateUpdateZOrder            = @"decorate_update_z_order";

@implementation MessageFactory

+ (NSDictionary *)MessageGenerateScreenRect:(CGRect)screenRect {
    if (CGRectIsNull(screenRect) || CGRectIsEmpty(screenRect))
        return nil;
    
    NSDictionary *message = @{kDataType: @(vDataTypeScreenSize),
                              kScreenSize: [NSValue valueWithCGRect:screenRect]};
    
    return message;
}

+ (NSDictionary *)MessageGeneratePhotoFrameSelected:(NSIndexPath *)selectedIndexPath {
    NSDictionary *message;
    
    if (selectedIndexPath == nil) {
        message = @{kDataType: @(vDataTypePhotoFrameSelected),
                    kPhotoFrameIndex: [NSNull null]};
        
        return message;
    }
    
    message = @{kDataType: @(vDataTypePhotoFrameSelected),
                kPhotoFrameIndex: selectedIndexPath};

    return message;
}

+ (NSDictionary *)MessageGeneratePhotoFrameRequestConfirm:(NSIndexPath *)selectedIndexPath {
    if (selectedIndexPath == nil)
        return nil;
    
    NSDictionary *message = @{kDataType: @(vDataTypePhotoFrameRequestConfirm),
                              kPhotoFrameIndex: selectedIndexPath,
                              kPhotoFrameConfirmTimestamp: @([[NSDate date] timeIntervalSince1970] * 1000)};
    
    return message;
}

+ (NSDictionary *)MessageGeneratePhotoFrameConfirmed:(BOOL)confirm {
    NSDictionary *message = @{kDataType: @(vDataTypePhotoFrameConfirmedAck),
                              kPhotoFrameConfirmedAck: @(confirm)};
    
    return message;
                              
}

+ (NSDictionary *)MessageGeneratePhotoEdit:(NSIndexPath *)editIndexPath {
    if (editIndexPath == nil)
        return nil;
    
    NSDictionary *message = @{kDataType: @(vDataTypeEditorPhotoEdit),
                              kEditorPhotoIndexPath: editIndexPath,
                              kEditorPhotoEditTimestamp: @([[NSDate date] timeIntervalSince1970] * 1000)};
    
    return message;
}

+ (NSDictionary *)MessageGeneratePhotoEditCanceled:(NSIndexPath *)editIndexPath {
    if (editIndexPath == nil)
        return nil;
    
    NSDictionary *message = @{kDataType: @(vDataTypeEditorPhotoEditCanceled),
                              kEditorPhotoIndexPath: editIndexPath};
    
    return message;
}

+ (NSDictionary *)MessageGeneratePhotoInsertCompleted:(NSIndexPath *)insertIndexPath success:(BOOL)success {
    NSDictionary *message = @{kDataType: @(vDataTypeEditorPhotoInsertedAck),
                              kEditorPhotoIndexPath: insertIndexPath,
                              kEditorPhotoInsertedAck: @(success)};
    
    return message;
}

+ (NSDictionary *)MessageGeneratePhotoDeleted:(NSIndexPath *)deleteIndexPath {
    if (deleteIndexPath == nil)
        return nil;
    
    NSDictionary *message = @{kDataType: @(vDataTypeEditorPhotoDeleted),
                              kEditorPhotoIndexPath:deleteIndexPath};
    
    return message;
}

+ (NSDictionary *)MessageGenerateDecorateDataEdit:(NSInteger)index {
    NSDictionary *message = @{kDataType: @(vDataTypeEditorDecorateEdit),
                              kEditorDecorateIndex: @(index),
                              kEditorDecorateEditTimestamp: @([[NSDate date] timeIntervalSince1970] * 1000)};
    
    return message;
}

+ (NSDictionary *)MessageGenerateDecorateDataEditCanceled:(NSInteger)index {
    NSDictionary *message = @{kDataType: @(vDataTypeEditorDecorateEditCanceled),
                            kEditorDecorateIndex: @(index)};
    
    return message;
}

+ (NSDictionary *)MessageGenerateDecorateDataInserted:(id)data timestamp:(NSNumber *)timestamp {
    if (data == nil)
        return nil;
    
    NSDictionary *message = @{kDataType: @(vDataTypeEditorDecorateInserted),
                              kEditorDecorateInsertedData: data,
                              kEditorDecorateInsertedTimestamp: timestamp};
    
    return message;
}

+ (NSDictionary *)MessageGenerateDecorateDataMoved:(NSInteger)index movedPoint:(CGPoint)movedPoint {
    if (CGPointEqualToPoint(movedPoint, CGPointZero))
        return nil;
    
    NSDictionary *message = @{kDataType: @(vDataTypeEditorDecorateUpdateMoved),
                              kEditorDecorateIndex: @(index),
                              kEditorDecorateUpdateMovedPoint: [NSValue valueWithCGPoint:movedPoint]};
    
    return message;
}

+ (NSDictionary *)MessageGenerateDecorateDataResized:(NSInteger)index resizedRect:(CGRect)resizedRect {
    if (CGRectIsNull(resizedRect) || CGRectIsEmpty(resizedRect))
        return nil;
    
    NSDictionary *message = @{kDataType: @(vDataTypeEditorDecorateUpdateResized),
                              kEditorDecorateIndex: @(index),
                              kEditorDecorateUpdateResizedRect: [NSValue valueWithCGRect:resizedRect]};
    
    return message;
}

+ (NSDictionary *)MessageGenerateDecorateDataRotated:(NSInteger)index rotatedAngle:(CGFloat)rotatedAngle {
    NSDictionary *message = @{kDataType: @(vDataTypeEditorDecorateUpdateRotated),
                              kEditorDecorateIndex: @(index),
                              kEditorDecorateUpdateRotatedAngle: @(rotatedAngle)};
    
    return message;
}

+ (NSDictionary *)MessageGenerateDecorateDataChangZOrder:(NSInteger)index {
    NSDictionary *message = @{kDataType: @(vDataTypeEditorDecorateUpdateZOrder),
                              kEditorDecorateIndex: @(index)};
    
    return message;
}

+ (NSDictionary *)MessageGenerateDecorateDataDeleted:(NSInteger)index {
    NSDictionary *message = @{kDataType: @(vDataTypeEditorDecorateDeleted),
                              kEditorDecorateIndex: @(index)};
    
    return message;
}

@end
