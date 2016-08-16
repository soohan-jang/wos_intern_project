//
//  PhotoStickerMenuView.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoStickerMenuViewDelegate;

@interface PhotoStickerMenuView : UIView

@property (weak, nonatomic) id<PhotoStickerMenuViewDelegate> delegate;

@end

@protocol PhotoStickerMenuViewDelegate <NSObject>
@required
- (void)stickerViewControllerDidSelected:(UIImage *)sticker;
- (void)stickerViewControllerDidClosed:(PhotoStickerMenuView *)viewController;

@end