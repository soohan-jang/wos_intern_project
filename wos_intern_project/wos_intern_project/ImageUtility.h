//
//  ImageUtility.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 23..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

#import <UIKit/UIkit.h>

typedef void (^ImageUtilityForGetFullScreenImageBlock)(UIImage *image);

extern NSString *const FILE_POSTFIX_CROPPED;
extern NSString *const FILE_POSTFIX_FULLSCREEN;

@interface ImageUtility : NSObject

+ (ImageUtility *)sharedInstance;

- (void)getFullScreenUIImageWithURL:(NSURL *)url resultBlock:(ImageUtilityForGetFullScreenImageBlock)resultBlock;

- (NSString *)saveImageAtTemporaryDirectoryForDummy:(UIImage *)image;

/**
 파일 생성 및 저장에 성공하면, 파일명을 반환한다. 경로는 NSTemporaryDirectory이다.
 생성 및 저장에 실패하면, nil을 반환한다.
 */
- (NSString *)saveImageAtTemporaryDirectoryWithFullscreenImage:(UIImage *)fullscreenImage croppedImage:(UIImage *)croppedImage;

/**
 파일명에 해당하는 임시파일을 삭제한다.
 */
- (void)removeTempImageWithFilename:(NSString *)filename;

/**
 임시파일 폴더에 위치한 모든 임시파일을 삭제한다.
 */
- (void)removeAllTempImages;

- (NSURL *)getFullscreenImageURLWithFilename:(NSString *)filename;
- (NSURL *)getCroppedImageURLWithFilename:(NSString *)filename;

@end
