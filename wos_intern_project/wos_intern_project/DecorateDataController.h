//
//  DecorateDataController.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoDecorateData.h"

@interface DecorateDataController : NSObject

/**
 그림 객체를 매니저에 저장한다.
 */
- (void)addDecorateData:(PhotoDecorateData *)decoData;

/**
 저장된 그림 객체의 위치정보를 갱신한다. 매니저 내부에 저장된 객체가 없을 시 작업을 수행하지 않는다.
 */
- (void)updateDecorateDataAtIndex:(NSInteger)index point:(CGPoint)point;

/**
 저장된 그림 객체의 크기정보를 갱신한다. 매니저 내부에 저장된 객체가 없을 시 작업을 수행하지 않는다.
 */
- (void)updateDecorateDataAtIndex:(NSInteger)index rect:(CGRect)rect;

/**
 저장된 그림 객체의 회전정보를 갱신한다. 매니저 내부에 저장된 객체가 없을 시 작업을 수행하지 않는다.
 */
- (void)updateDecorateDataAtIndex:(NSInteger)index angle:(CGFloat)angle;

/**
 저장된 그림 객체의 Z-order를 갱신한다. 매니저 내부에 저장된 객체가 없을 시 작업을 수행하지 않는다.
 */
- (void)updateDecorateDataZOrderAtIndex:(NSInteger)index;

/**
 저장된 그림 객체를 삭제한다. 매니저 내부에 저장된 객체가 없을 시 작업을 수행하지 않는다.
 */
- (void)deleteDecorateDataAtIndex:(NSInteger)index;

/**
 전달된 객체의 인덱스를 가져온다. 매니저 내부에 저장된 객체가 없을 시 NSNotFound를 반환한다.
 */
- (NSUInteger)getIndexOfDecorateData:(PhotoDecorateData *)data;

/**
 저장된 그림 객체의 정보를 가져온다. 매니저 내부에 저장된 객체가 없을 시 nil을 반환한다.
 */
- (PhotoDecorateData *)getDecorateDataAtIndex:(NSInteger)index;

/**
 저장된 모든 그림객체를 UIView로 변환하여 NSArray에 저장한 뒤 반환한다. 매니저 내부에 저장된 객체가 없을 시 nil을 반환한다.
 */
- (NSArray *)getDecorateViewArray;

/**
 저장된 모든 그림 객체를 할당된 timestamp를 기준으로 오름차순 정렬한다.
 */
- (void)sortDecorateDatas;

/**
 내부에 저장된 값이 있는지에 대한 여부를 반환한다.
 */
- (BOOL)isEmpty;

/**
 내부에 저장된 값의 개수를 반환한다. 매니저 내부에 객체를 저장하는 변수가 nil이거나, 저장된 객체가 없을 시 0을 반환한다.
 */
- (NSInteger)getCount;

@end
