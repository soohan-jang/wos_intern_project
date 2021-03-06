//
//  PhotoFrameDataController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PEPhotoFrameControllerDelegate;

@interface PEPhotoFrameMessageSender : NSObject

- (BOOL)sendSelectPhotoFrameMessage:(NSIndexPath *)indexPath;
- (BOOL)sendDeselectPhotoFrameMessage:(NSIndexPath *)indexPath;

- (BOOL)sendPhotoFrameConfrimRequestMessage:(NSIndexPath *)indexPath;
- (BOOL)sendPhotoFrameConfirmAckMessage:(BOOL)confrimAck;

@end

@interface PEPhotoFrameController : NSObject

@property (weak, nonatomic) id<PEPhotoFrameControllerDelegate> delegate;
@property (strong, nonatomic) PEPhotoFrameMessageSender *dataSender;

@property (strong, nonatomic, readonly) NSIndexPath *ownSelectedIndexPath;
@property (strong, nonatomic, readonly) NSIndexPath *otherSelectedIndexPath;

/**
 * @brief PhotoFrameDataController 객체를 생성한다.
 * @param size : Cell들이 위치할 CollectionView의 크기
 * @return PhotoFrameDataController : 생성된 객체
 */
- (instancetype)initWithCollectionViewSize:(CGSize)size;

/**
 * @brief PhotoFrameDataController의 프로퍼티를 해제한다. SelectPhtoFrameVC에서 EditPhotoVC로 넘어갈 때
 */
- (void)clearController;

/**
 * @brief isOwnSelection 여부에 따라 ownSelectedIndexPath 혹은 ohterSelectedIndexPath를 갱신한다.
 * @param indexPath : 상태를 갱신할 인덱스패스
 * @param isOwnSelection : 자신의 입력에 의한 갱신인지(YES), 상대방에 의한 갱신인지(NO)에 대한 여부
 * @return void
 */
- (void)setSelectedCellAtIndexPath:(NSIndexPath *)indexPath isOwnSelection:(BOOL)isOwnSelection;
- (void)setDeselectedCellAtIndexPath:(NSIndexPath *)indexPath isOwnSelection:(BOOL)isOwnSelection;

- (CGSize)sizeOfCell:(CGSize)size;

- (UIEdgeInsets)edgeInsets:(CGSize)size;

/**
 * @brief 인덱스패스에 해당하는 Cell의 이미지를 가져온다.
 * @param indexPath : 이미지를 가져올 Cell을 가리키는 인덱스패스
 * @return UIImage : 해당되는 Cell의 이미지
 */
- (UIImage *)cellImageAtIndexPath:(NSIndexPath *)indexPath;

/**
 * @brief 현재 내가 선택한 Cell과 상대방이 선택한 Cell이 동일한지 확인한다.
 * @return BOOL : 같으면 YES, 아니면 NO를 반환한다.
 */
- (BOOL)isEqualBothSelectedIndexPath;

/**
 * @brief Cell들의 enabled 속성을 변경한다. userInteractionEnable를 변경하여 이벤트를 받거나 받지 못하게 설정한다.
 * @param enabled : enable 속성을 결정하는 BOOL 값
 * @return : void
 */
- (void)setEnableCells:(BOOL)enabled;

@end

/**
 * @brief PhotoFrameSelectCellManager의 델리게이트 프로토콜이다.
 *        Cell Data가 갱신되었을 때 호출된다.
 *        didUpdateCellEnabled               : setEnableCells에 대응된다. 셀의 enabled 속성이 변경되었을 때 호출된다.
 *        didUpdateCellStateWithDoneActivate : receivedPhotoFrameSelected애 대응된다. 상대방이 선택한 셀이 변경되었을 때 호출되며, 상대방과 내가 선택한 셀이 동일한지를 의미하는 activate를 함께 전달한다.
 */
@protocol PEPhotoFrameControllerDelegate <NSObject>
@required
- (void)didUpdateCellEnabled:(BOOL)enabled;
- (void)didUpdateCellStateWithDoneActivate:(BOOL)activate;
- (void)didReceiveRequestPhotoFrameConfirm:(NSIndexPath *)indexPath;
- (void)didReceiveRequestPhotoFrameConfirmAck:(BOOL)confirmAck;

@end