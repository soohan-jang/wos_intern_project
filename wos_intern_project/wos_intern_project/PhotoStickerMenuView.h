//
//  PhotoStickerMenuView.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecorateData.h"

@protocol PhotoStickerMenuViewDelegate;

@interface PhotoStickerMenuView : UIView

@property (weak, nonatomic) id<PhotoStickerMenuViewDelegate> delegate;

@end

/**
 @berif 스티커를 선택하는 View에서 발생하는 일을 처리하기 위한 Delegate이다. 스티커가 선택되었을 때와 View가 닫혔을 때 호출된다.
 */
@protocol PhotoStickerMenuViewDelegate <NSObject>
@required
- (void)stickerViewControllerDidSelected:(DecorateData *)decorateData;
- (void)stickerViewControllerDidClosed;

@end