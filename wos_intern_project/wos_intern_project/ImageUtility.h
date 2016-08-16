//
//  ImageUtility.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 23..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIkit.h>

typedef void (^ImageUtilityForGetFullScreenImageBlock)(UIImage *image);

/**
 해당 객체의 네이밍에 대해서 고민해볼 필요성이 있다.
 */
@interface ImageUtility : NSObject

/**
 Fullscreen Image를 가져온다. URL은 ImagePicker에서 받아오는 ReferenceURL(Assets://)를 사용한다.
 UIImage의 반환은 Block 구문을 통해 반환한다.
 */
+ (void)getFullscreenUIImageAthURL:(NSURL *)url resultBlock:(ImageUtilityForGetFullScreenImageBlock)resultBlock;

/**
 파일 생성 및 저장에 성공하면, 파일명을 반환한다. 경로는 NSTemporaryDirectory이다.
 생성 및 저장에 실패하면, nil을 반환한다.
 */
+ (NSString *)saveImageAtTemporaryDirectoryWithFullscreenImage:(UIImage *)fullscreenImage withCroppedImage:(UIImage *)croppedImage;

/**
 파일명에 해당하는 임시파일을 삭제한다.
 */
+ (void)removeTemporaryImageWithFilename:(NSString *)filename;

/**
 임시파일 폴더에 위치한 모든 임시파일을 삭제한다.
 */
+ (void)removeAllTemporaryImages;

/**
 filename으로 fullscreen image의 URL을 생성한다.
 URL의 구성은 tempdir/[filename]+_fullscreen의 형태를 지닌다.
 */
+ (NSURL *)generateFullscreenImageURLWithFilename:(NSString *)filename;

/**
 filename으로 fullscreen image의 URL을 생성한다.
 URL의 구성은 tempdir/[filename]+_fullscreen의 형태를 지닌다.
 */
+ (NSURL *)generateCroppedImageURLWithFilename:(NSString *)filename;

+ (NSString *)generatePhotoFrameImageWithIndex:(NSInteger)index;
+ (NSString *)generatePhotoFrameImageWithIndex:(NSInteger)index postfix:(NSString *)postfix;
+ (NSString *)generatePhotoStickerImageWithIndex:(NSInteger)index;
+ (UIImage *)renderImageNamed:(NSString *)imageName renderColor:(UIColor *)color;

@end