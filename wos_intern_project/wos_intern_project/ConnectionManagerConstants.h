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
extern NSString *const SERVICE_TYPE;

/** VALUE_DATA_TYPE으로 시작되는 값과 매칭되는 키 값 **/
extern NSString *const KEY_DATA_TYPE;

/** KEY_DATA_TYPE에 값으로 설정되는 값 **/
extern NSInteger const VALUE_DATA_TYPE_SCREEN_SIZE;

extern NSInteger const VALUE_DATA_TYPE_PHOTO_FRAME_SELECTED;
extern NSInteger const VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM;
extern NSInteger const VALUE_DATA_TYPE_PHOTO_FRAME_CONFIRM_ACK;
extern NSInteger const VALUE_DATA_TYPE_PHOTO_FRAME_DISCONNECTED;

extern NSInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_INSERT;
extern NSInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_INSERT_ACK;
extern NSInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT;
extern NSInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_EDIT_CANCELED;
extern NSInteger const VALUE_DATA_TYPE_EDITOR_PHOTO_DELETE;

extern NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_EDIT;
extern NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_EDIT_CANCELED;
extern NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_INSERT;
extern NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_MOVED;
extern NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_RESIZED;
extern NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_ROTATED;
extern NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_UPDATE_Z_ORDER;
extern NSInteger const VALUE_DATA_TYPE_EDITOR_DRAWING_DELETE;
extern NSInteger const VALUE_DATA_TYPE_EDITOR_DICONNECTED;

/** 스크린 크기의 너비와 높이 값에 대한 키 값 **/
/** 너비와 높이가 NSNumber floatValue 값으로 매칭된다 **/
extern NSString *const KEY_SCREEN_SIZE_WIDTH;
extern NSString *const KEY_SCREEN_SIZE_HEIGHT;

/** 선택된 사진 액자 인덱스 값에 대한 키 값 **/
/** 인덱스값이 NSIndexPath 값으로 매칭된다 **/
extern NSString *const KEY_PHOTO_FRAME_SELECTED;

/** 사진 선택 완료 요청에 대한 응답값에 대한 키 값 **/
/** NSNumber boolValue 값으로 매칭된다 **/
extern NSString *const KEY_PHOTO_FRAME_CONFIRM_ACK;

/** 사진 입력/삭제, 그림 객체 입력/갱신/삭제에 대한 키 값 **/
/** 아직 미정. 근데 아마 사진은 byte[], 그림 객체는 DrawingObject 값으로 매칭될 듯 **/
extern NSString *const KEY_EDITOR_PHOTO_INSERT_INDEX;
extern NSString *const KEY_EDITOR_PHOTO_INSERT_DATA_TYPE;
extern NSString *const KEY_EDITOR_PHOTO_INSERT_DATA;
extern NSString *const KEY_EDITOR_PHOTO_INSERT_ACK;
extern NSString *const KEY_EDITOR_PHOTO_EDIT_INDEX;
extern NSString *const KEY_EDITOR_PHOTO_DELETE_INDEX;

extern NSString *const KEY_EDITOR_DRAWING_EDIT_ID;
extern NSString *const KEY_EDITOR_DRAWING_INSERT_DATA;
extern NSString *const KEY_EDITOR_DRAWING_INSERT_TIMESTAMP;
extern NSString *const KEY_EDITOR_DRAWING_UPDATE_ID;
//extern NSString *const KEY_EDITOR_DRAWING_UPDATE_DATA;
extern NSString *const KEY_EDITOR_DRAWING_UPDATE_MOVED_X;
extern NSString *const KEY_EDITOR_DRAWING_UPDATE_MOVED_Y;
extern NSString *const KEY_EDITOR_DRAWING_UPDATE_RESIZED_WIDTH;
extern NSString *const KEY_EDITOR_DRAWING_UPDATE_RESIZED_HEIGHT;
extern NSString *const KEY_EDITOR_DRAWING_UPDATE_ROTATED_ANGLE;
//extern NSString *const KEY_EDITOR_DRAWING_UPDATE_Z_ORDER;
extern NSString *const KEY_EDITOR_DRAWING_DELETE_ID;