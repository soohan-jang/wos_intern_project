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
NSString *const kPhotoFrameSelected                    = @"photo_frame_select";

NSString *const kPhotoFrameConfirmIndex                = @"photo_frame_confirm_index";
NSString *const kPhotoFrameConfirmTimestamp            = @"photo_frame_confirm_timestamp";

/** 사진 선택 완료 요청에 대한 응답값에 대한 키 값 **/
/** NSNumber boolValue 값으로 매칭된다 **/
NSString *const kPhotoFrameConfirmedAck                = @"photo_frame_confirmed_ack";

/** 사진 입력/삭제, 그림 객체 입력/갱신/삭제에 대한 키 값 **/
NSString *const kEditorPhotoEditIndexPath              = @"photo_edit_indexpath";
NSString *const kEditorPhotoEditTimestamp              = @"photo_edit_timestamp";
NSString *const kEditorPhotoEditCanceledIndexPath      = @"photo_edit_canceled_indexpath";
NSString *const kEditorPhotoEditInterruptIndexPath     = @"photo_edit_interrupt_indexpath";

NSString *const kEditorPhotoInsertedIndexPath          = @"photo_insert_indexpath";
NSString *const kEditorPhotoInsertedDataType           = @"photo_insert_data_type";
NSString *const kEditorPhotoInsertedData               = @"photo_insert_data";
NSString *const kEditorPhotoInsertedAck                = @"photo_insert_ack";
NSString *const kEditorPhotoDeletedIndexPath           = @"photo_delete_indexpath";

NSString *const kEditorDecorateEditIndex               = @"decorate_edit_index";
NSString *const kEditorDecorateEditTimestamp           = @"decorate_edit_timestamp";
NSString *const kEditorDecorateEditCanceledIndex       = @"decorate_edit_canceled_index";
NSString *const kEditorDecorateEditInterruptIndex      = @"decorate_edit_interrupt_index";

NSString *const kEditorDecorateInsertedData            = @"decorate_insert_data";
NSString *const kEditorDecorateInsertedTimestamp       = @"decorate_insert_timestamp";
NSString *const kEditorDecorateUpdateIndex             = @"decorate_update_index";
NSString *const kEditorDecorateUpdateMovedPoint        = @"decorate_update_moved_point";
NSString *const kEditorDecorateUpdateResizedRect       = @"decorate_update_resized_rect";
NSString *const kEditorDecorateUpdateRotatedAngle      = @"decorate_update_rotated_angle";
NSString *const kEditorDecorateUpdateZOrder            = @"decorate_update_z_order";
NSString *const kEditorDecorateDeletedIndex            = @"decorate_deleted_index";

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
                    kPhotoFrameSelected: [NSNull null]};
        
        return message;
    }
    
    message = @{kDataType: @(vDataTypePhotoFrameSelected),
                kPhotoFrameSelected: selectedIndexPath};

    return message;
}

+ (NSDictionary *)MessageGeneratePhotoFrameRequestConfirm:(NSIndexPath *)selectedIndexPath {
    if (selectedIndexPath == nil)
        return nil;
    
    NSDictionary *message = @{kDataType: @(vDataTypePhotoFrameRequestConfirm),
                              kPhotoFrameConfirmIndex: selectedIndexPath,
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
                              kEditorPhotoEditIndexPath: editIndexPath,
                              kEditorPhotoEditTimestamp: @([[NSDate date] timeIntervalSince1970] * 1000)};
    
    return message;
}

+ (NSDictionary *)MessageGeneratePhotoEditCanceled:(NSIndexPath *)editIndexPath {
    if (editIndexPath == nil)
        return nil;
    
    NSDictionary *message = @{kDataType: @(vDataTypeEditorPhotoEditCanceled),
                              kEditorPhotoEditCanceledIndexPath: editIndexPath};
    
    return message;
}

+ (NSDictionary *)MessageGeneratePhotoEditInterrupt:(NSIndexPath *)interruptIndexPath {
    if (interruptIndexPath == nil)
        return nil;
    
    NSDictionary *message = @{kDataType: @(vDataTypeEditorPhotoEditInterrupt),
                              kEditorPhotoEditInterruptIndexPath: interruptIndexPath};
    
    return message;
}

+ (NSDictionary *)MessageGeneratePhotoInsertCompleted:(NSIndexPath *)insertIndexPath success:(BOOL)success {
    NSDictionary *message = @{kDataType: @(vDataTypeEditorPhotoInsertedAck),
                              kEditorPhotoInsertedIndexPath: insertIndexPath,
                              kEditorPhotoInsertedAck: @(success)};
    
    return message;
}

+ (NSDictionary *)MessageGeneratePhotoDeleted:(NSIndexPath *)deleteIndexPath {
    if (deleteIndexPath == nil)
        return nil;
    
    NSDictionary *message = @{kDataType: @(vDataTypeEditorPhotoDeleted),
                              kEditorPhotoDeletedIndexPath:deleteIndexPath};
    
    return message;
}

+ (NSDictionary *)MessageGenerateDecorateDataEdit:(NSInteger)index {
    NSDictionary *message = @{kDataType: @(vDataTypeEditorDecorateEdit),
                              kEditorDecorateEditIndex: @(index),
                              kEditorDecorateEditTimestamp: @([[NSDate date] timeIntervalSince1970] * 1000)};
    
    return message;
}

+ (NSDictionary *)MessageGenerateDecorateDataEditCanceled:(NSInteger)index {
    NSDictionary *message = @{kDataType: @(vDataTypeEditorDecorateEditCanceled),
                            kEditorDecorateEditCanceledIndex: @(index)};
    
    return message;
}

+ (NSDictionary *)MessageGenerateDecorateDataEditInterrupt:(NSInteger)index {
    NSDictionary *message = @{kDataType: @(vDataTypeEditorDecorateEditInterrupt),
      kEditorDecorateEditInterruptIndex: @(index)};
    
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
                              kEditorDecorateUpdateIndex: @(index),
                              kEditorDecorateUpdateMovedPoint: [NSValue valueWithCGPoint:movedPoint]};
    
    return message;
}

+ (NSDictionary *)MessageGenerateDecorateDataResized:(NSInteger)index resizedRect:(CGRect)resizedRect {
    if (CGRectIsNull(resizedRect) || CGRectIsEmpty(resizedRect))
        return nil;
    
    NSDictionary *message = @{kDataType: @(vDataTypeEditorDecorateUpdateResized),
                              kEditorDecorateUpdateIndex: @(index),
                              kEditorDecorateUpdateResizedRect: [NSValue valueWithCGRect:resizedRect]};
    
    return message;
}

+ (NSDictionary *)MessageGenerateDecorateDataRotated:(NSInteger)index rotatedAngle:(CGFloat)rotatedAngle {
    NSDictionary *message = @{kDataType: @(vDataTypeEditorDecorateUpdateRotated),
                              kEditorDecorateUpdateIndex: @(index),
                              kEditorDecorateUpdateRotatedAngle: @(rotatedAngle)};
    
    return message;
}

+ (NSDictionary *)MessageGenerateDecorateDataChangZOrder:(NSInteger)index {
    NSDictionary *message = @{kDataType: @(vDataTypeEditorDecorateUpdateZOrder),
                              kEditorDecorateUpdateIndex: @(index)};
    
    return message;
}

+ (NSDictionary *)MessageGenerateDecorateDataDeleted:(NSInteger)index {
    NSDictionary *message = @{kDataType: @(vDataTypeEditorDecorateDeleted),
                              kEditorDecorateDeletedIndex: @(index)};
    
    return message;
}

@end
