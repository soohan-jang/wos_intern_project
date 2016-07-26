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

extern NSInteger const IMAGE_RESIZE_CROPPED;
extern NSInteger const IMAGE_RESIZE_STANDARD;

extern NSString *const FILE_POSTFIX_CROPPED;
extern NSString *const FILE_POSTFIX_STANDARD;

@interface ImageUtility : NSObject

+ (ImageUtility *)sharedInstance;

/**
 파일 생성 및 저장에 성공하면, 파일명을 반환한다. 경로는 NSTemporaryDirectory이다.
 생성 및 저장에 실패하면, nil을 반환한다.
 */
- (BOOL)makeTempImageWithUIImage:(UIImage *)image filename:(NSString *)filename prefixOption:(NSInteger)option;

/**
 파일 생성 및 저장에 성공하면, 파일명을 반환한다. 경로는 NSTemporaryDirectory이다.
 생성 및 저장에 실패하면, nil을 반환한다.
 */
- (BOOL)makeTempImageWithAssetRepresentation:(ALAssetRepresentation *) representation;

/**
 생성된 원본 임시파일을 기준으로 크기를 조절한다. 옵션은 thumbnail과 standard로 구분된다.
 리사이즈된 임시파일은 NSTemporaryDirectory에 저장되며, 파일명은 공유하되 뒤에 postfix를 붙여 구분한다.
 postfix는 _thumbnail과 _standard이다.
 */
- (BOOL)makeTempImageWithFilename:(NSString *)filename resizeOption:(NSInteger)option;

/**
 파일명에 해당하는 임시파일을 삭제한다.
 */
- (void)removeTempImageWithFilename:(NSString *)filename;

/**
 임시파일 폴더에 위치한 모든 임시파일을 삭제한다.
 */
- (void)removeAllTempImages;

@end
