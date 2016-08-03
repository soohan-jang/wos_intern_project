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
NSString *const SERVICE_TYPE                                  = @"Co-PhotoEditor";

/** VALUE_DATA_TYPE으로 시작되는 값과 매칭되는 키 값 **/
NSString *const KEY_DATA_TYPE                                 = @"data_type";

/** KEY_DATA_TYPE에 값으로 설정되는 값 **/
//NSNumber로 설정하면 컴파일 시에 초기화되지 않아서 NSUInteger로 설정하였다.
NSInteger const VALUE_DATA_TYPE_SCREEN_SIZE                    = 100;

NSInteger const VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED           = 200;
NSInteger const VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM            = 201;
NSInteger const VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM_ACK        = 202;

NSInteger const VALUE_DATA_TYPE_PHOTO_FRAME_DISCONNECTED       = 300;

NSInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_INSERT            = 400;
NSInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_INSERT_ACK        = 401;
NSInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT              = 402;
NSInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED     = 403;
NSInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_DELETE            = 404;

NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_EDIT            = 500;
NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_EDIT_CANCELED   = 501;
NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_INSERT          = 502;
NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_MOVED    = 503;
NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_RESIZED  = 504;
NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_ROTATED  = 505;
NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_Z_ORDER  = 506;
NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_DELETE          = 507;

NSInteger const VALUE_DATA_TYPE_EDITOR_DICONNECTED             = 600;

/** 스크린 크기의 너비와 높이 값에 대한 키 값 **/
/** 너비와 높이가 NSNumber floatValue 값으로 매칭된다 **/
NSString *const KEY_SCREEN_SIZE_WIDTH                           = @"screen_size_width";
NSString *const KEY_SCREEN_SIZE_HEIGHT                          = @"screen_size_height";

/** 선택된 사진 액자 인덱스 값에 대한 키 값 **/
/** 인덱스값이 NSIndexPath 값으로 매칭된다 **/
NSString *const KEY_PHOTO_FRAME_SELECTED                        = @"photo_frame_select";

/** 사진 선택 완료 요청에 대한 응답값에 대한 키 값 **/
/** NSNumber boolValue 값으로 매칭된다 **/
NSString *const KEY_PHOTO_FRAME_CONFIRM_ACK                     = @"photo_frame_confirm_ack";

/** 사진 입력/삭제, 그림 객체 입력/갱신/삭제에 대한 키 값 **/
/** 아직 미정. 근데 아마 사진은 byte[], 그림 객체는 DrawingObject 값으로 매칭될 듯 **/
NSString *const KEY_EDITOR_PHOTO_INSERT_INDEX                   = @"photo_insert_index";
NSString *const KEY_EDITOR_PHOTO_INSERT_DATA_TYPE               = @"photo_insert_data_type";
NSString *const KEY_EDITOR_PHOTO_INSERT_DATA                    = @"photo_insert_data";
NSString *const KEY_EDITOR_PHOTO_INSERT_ACK                     = @"photo_insert_ack";
NSString *const KEY_EDITOR_PHOTO_EDIT_INDEX                     = @"photo_edit_index";
NSString *const KEY_EDITOR_PHOTO_DELETE_INDEX                   = @"photo_delete_index";

NSString *const KEY_EDITOR_DRAWING_EDIT_ID                      = @"drawing_edit_id";
NSString *const KEY_EDITOR_DRAWING_INSERT_DATA                  = @"drawing_insert_data";
NSString *const KEY_EDITOR_DRAWING_INSERT_TIMESTAMP             = @"drawing_insert_timestamp";
NSString *const KEY_EDITOR_DRAWING_UPDATE_ID                    = @"drawing_update_id";
//NSString *const KEY_EDITOR_DRAWING_UPDATE_DATA                  = @"drawing_update_data";
NSString *const KEY_EDITOR_DRAWING_UPDATE_MOVED_X               = @"drawing_update_moved_x";
NSString *const KEY_EDITOR_DRAWING_UPDATE_MOVED_Y               = @"drawing_update_moved_y";;
NSString *const KEY_EDITOR_DRAWING_UPDATE_RESIZED_WIDTH         = @"drawing_update_resized_width";;
NSString *const KEY_EDITOR_DRAWING_UPDATE_RESIZED_HEIGHT        = @"drawing_update_resized_height";
NSString *const KEY_EDITOR_DRAWING_UPDATE_ROTATED_ANGLE         = @"drawing_update_rotated_angle";
//NSString *const KEY_EDITOR_DRAWING_UPDATE_Z_ORDER               = @"drawing_update_z_order";
NSString *const KEY_EDITOR_DRAWING_DELETE_ID                    = @"drawing_delete_id";