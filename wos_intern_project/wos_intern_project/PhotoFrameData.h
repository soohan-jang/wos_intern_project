//
//  PhotoFrameData.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIImage.h>

@interface PhotoFrameData : NSObject

@property (strong, nonatomic) UIColor *stateColor;

/**
 * @brief 객체를 생성한다.
 * @param indexPath : 이 객체가 가리킬 indexPath를 지정한다.
 * @return PhotoFrameSelectCellData : 생성된 객체
 */
- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath;

/**
 * @brief isOwnSelection 여부에 따라 ownSelected 혹은 ohterSelected를 갱신한다.
 * @param state : 선택 여부.
 * @param isOwnSelection : 자신의 입력에 의한 갱신인지(YES), 상대방에 의한 갱신인지(NO)에 대한 여부
 * @return void
 */
- (void)updateCellState:(BOOL)state isOwnSelection:(BOOL)isOwnSelection;

/**
 * @brief 셀의 상태가 나와 상대방 모두가 선택한 상태인지를 확인한다.
 * @return 둘 다 선택한 경우엔 YES, 아닌 경우엔 NO를 반환한다.
 */
- (BOOL)isBothSelected;

@end