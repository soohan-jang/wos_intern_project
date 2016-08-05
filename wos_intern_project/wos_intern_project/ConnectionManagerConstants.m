//
//  ConnectionManagerConstants.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 3..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "ConnectionManagerConstants.h"

/** MCSession Service Type **/
/** 이 값이 일치하는 장비만 Bluetooth 장비목록에 노출된다 **/
NSString *const ApplicationBluetoothServiceType        = @"Co-PhotoEditor";

/** VALUE_DATA_TYPE으로 시작되는 값과 매칭되는 키 값 **/
NSString *const kDataType                              = @"data_type";

/** 스크린 크기의 너비와 높이 값에 대한 키 값 **/
/** 너비와 높이가 NSNumber floatValue 값으로 매칭된다 **/
NSString *const kScreenWidth                           = @"screen_size_width";
NSString *const kScreenHeight                          = @"screen_size_height";

/** 선택된 사진 액자 인덱스 값에 대한 키 값 **/
/** 인덱스값이 NSIndexPath 값으로 매칭된다 **/
NSString *const kPhotoFrameSelected                    = @"photo_frame_select";

/** 사진 선택 완료 요청에 대한 응답값에 대한 키 값 **/
/** NSNumber boolValue 값으로 매칭된다 **/
NSString *const kPhotoFrameSelectedConfirmAck          = @"photo_frame_confirm_ack";

/** 사진 입력/삭제, 그림 객체 입력/갱신/삭제에 대한 키 값 **/
/** 아직 미정. 근데 아마 사진은 byte[], 그림 객체는 DrawingObject 값으로 매칭될 듯 **/
NSString *const kEditorPhotoInsertIndex                = @"photo_insert_index";
NSString *const kEditorPhotoInsertDataType             = @"photo_insert_data_type";
NSString *const kEditorPhotoInsertData                 = @"photo_insert_data";
NSString *const kEditorPhotoInsertAck                  = @"photo_insert_ack";
NSString *const kEditorPhotoEditIndex                  = @"photo_edit_index";
NSString *const kEditorPhotoDeleteIndex                = @"photo_delete_index";

NSString *const kEditorDrawingEditID                   = @"drawing_edit_id";
NSString *const kEditorDrawingInsertData               = @"drawing_insert_data";
NSString *const kEditorDrawingInsertTimestamp          = @"drawing_insert_timestamp";
NSString *const kEditorDrawingUpdateID                 = @"drawing_update_id";
//NSString *const kEditorDrawingUpdateData               = @"drawing_update_data";
NSString *const kEditorDrawingUpdateMovedX             = @"drawing_update_moved_x";
NSString *const kEditorDrawingUpdateMovedY             = @"drawing_update_moved_y";
NSString *const kEditorDrawingUpdateResizedX           = @"drawing_update_resized_x";
NSString *const kEditorDrawingUpdateResizedY           = @"drawing_update_resized_y";
NSString *const kEditorDrawingUpdateResizedWidth       = @"drawing_update_resized_width";
NSString *const kEditorDrawingUpdateResizedHeight      = @"drawing_update_resized_height";
NSString *const kEditorDrawingUpdateRotatedAngle       = @"drawing_update_rotated_angle";
//NSString *const kEditorDrawingUpdateZOrder             = @"drawing_update_z_order";
NSString *const kEditorDrawingDeleteID                 = @"drawing_delete_id";