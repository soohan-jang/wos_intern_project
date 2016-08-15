//
//  PhotoAttachStickerMenuViewController.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 8. 15..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoAttachStickerMenuViewControllerDelegate;

@interface PhotoAttachStickerMenuViewController : UIViewController

@property (weak, nonatomic) id<PhotoAttachStickerMenuViewControllerDelegate> delegate;

@end

@protocol PhotoAttachStickerMenuViewControllerDelegate <NSObject>
@required
- (void)stickerViewControllerDidFinished:(UIViewController *)viewController sticker:(UIImage *)sticker;
- (void)stickerViewControllerDidCancelled:(UIViewController *)viewController;

@end