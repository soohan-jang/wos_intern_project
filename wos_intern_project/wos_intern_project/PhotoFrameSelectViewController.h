//
//  PhotoFrameSelectViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ConnectionManager.h"
#import "WMProgressHUD.h"

#import "PhotoFrameSelectViewCell.h"
#import "PhotoEditorViewController.h"


@interface PhotoFrameSelectViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSIndexPath *ownSelectedFrameIndex;
@property (nonatomic, strong) NSIndexPath *connectedPeerSelectedFrameIndex;

- (IBAction)backAction:(id)sender;
- (IBAction)doneAction:(id)sender;

/**
 NotificationCenter에 필요한 Observer를 등록한다.
 액자 선택, 액자 선택 해제를 처리하기 위한 Observer를 등록한다.
 */
- (void)addObservers;

/**
 NotificationCenter에 등록한 Observer를 등록해제한다.
 액자 선택, 액자 선택 해제를 처리하기 위한 Observer를 등록해제한다.
 */
- (void)removeObservers;


/**
 indexPath, ownSelectedFrameIndex, connectedPeerSelectedFrameIndex를 교차비교하여 액자의 상태를 변경한다.
 */
- (void)frameStateChangeAtIndex:(NSIndexPath *)indexPath;

/**
 indexPath에 해당되는 액자의 상태를 아무도 선택하지 않음으로 변경한다.
 postFix는 변경되는 액자의 색을 의미한다. 값은 다음과 같다.
 0 : 아무도 선택하지 않은 액자.
 1 : 본인만 선택한 액자.
 2 : 상대방만 선택한 액자.
 3 : 두 사용자 모두가 선택한 액자.
 */

- (void)frameImageChangeAtIndex:(NSIndexPath *)indexPath state:(NSUInteger)state;

/**
 상대방에게 액자를 선택헀음을 알리기 위해 호출되는 함수이다.
 */
- (void)sendFrameSelected;

/**
 상대방에게 액자를 선택해제했음을 알리기 위해 호출되는 함수이다.
 */
- (void)sendFrameDeselect;

/**
 상대방이 액자를 선택했을 때 호출되는 함수이다. 이 함수는 NotificationCenter에 의해 호출된다.
 */
- (void)receivedFrameSelected:(NSNotification *)notification;


/**
 상대방이 액자를 선택해제했을 때 호출되는 함수이다. 이 함수는 NotificationCenter에 의해 호출된다.
 */
- (void)receivedFrameDeselected:(NSNotification *)notification;

@end