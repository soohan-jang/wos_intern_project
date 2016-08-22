//
//  PhotoInputTextMenuView.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 11..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecorateData.h"

@protocol PhotoInputTextMenuViewDelegate;

@interface PhotoInputTextMenuView : UIView

@property (weak, nonatomic) id<PhotoInputTextMenuViewDelegate> delegate;

@end

/**
 @berif 텍스트를 입력하는 View에서 발생하는 일을 처리하기 위한 Delegate이다. 텍스트 입력이 완료/취소되었을 때의 상황을 Delegate로 전파한다.
 */
@protocol PhotoInputTextMenuViewDelegate <NSObject>
@required
/**
 @berif 텍스트 입력이 완료되었을 때 텍스트 영역의 경계를 계산하여, Capture한 UIImage를 전달한다.
 */
- (void)inputTextMenuViewDidFinished:(DecorateData *)decorateData;
/**
 @berif 텍스트 입력이 취소되었을 때 이를 알린다.
 */
- (void)inputTextMenuViewDidCancelled;

@end