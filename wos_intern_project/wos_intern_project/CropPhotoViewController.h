//
//  PhotoCropViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 25..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CropPhotoViewControllerDelegate;

@interface CropPhotoViewController : UIViewController

@property (weak, nonatomic) id<CropPhotoViewControllerDelegate> delegate;

- (void)setCropAreaSize:(CGSize)size;
- (void)setImageUrl:(NSURL *)url;
- (void)setImage:(UIImage *)image;
- (void)setImage:(UIImage *)image filiterType:(NSInteger)filterType;

@end

/**
 사진을 편집하는 ViewController의 Delegate이다.
 이 Delegate는 작업이 완료되었을 때와 취소되었을 때의 메시지를 전달한다.
 */
@protocol CropPhotoViewControllerDelegate <NSObject>
@required
/**
 편집이 완료된 후에 원본 이미지와 편집된 이미지를 전달한다.
 */
- (void)cropViewControllerDidFinished:(UIImage *)fullscreenImage croppedImage:(UIImage *)croppedImage filterType:(NSInteger)filterType;
/**
 편집이 취소되었음을 알린다.
 */
- (void)cropViewControllerDidCancelled;

@end