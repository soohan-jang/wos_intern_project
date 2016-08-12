//
//  ImageUtility.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 23..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "ImageUtility.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "CommonConstants.h"

@implementation ImageUtility

+ (void)getFullscreenUIImageAthURL:(NSURL *)url resultBlock:(ImageUtilityForGetFullScreenImageBlock)resultBlock {
    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
    
    [assetslibrary assetForURL:url resultBlock:^(ALAsset *asset) {
        if (asset == nil) {
            [assetslibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream
                                   usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                       if (!group) {
                                           return;
                                       }
                                       
                                       [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                           if (result && [result.defaultRepresentation.url isEqual:url]) {
                                               resultBlock([UIImage imageWithCGImage:result.defaultRepresentation.fullScreenImage]);
                                               *stop = YES;
                                           }
                                       }];
                                   }
                                 failureBlock:^(NSError *error) {
                                     if (error) {
                                         NSLog(@"Error: Cannot load asset from photo stream - %@", [error localizedDescription]);
                                     }
                                     
                                     resultBlock(nil);
                                 }];
        } else {
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            CGImageRef imageRef = representation.fullScreenImage;
            
            if (imageRef == nil) {
                imageRef = representation.fullResolutionImage;
                
                if (imageRef == nil) {
                    resultBlock(nil);
                } else {
                    resultBlock([UIImage imageWithCGImage:imageRef]);
                }
            } else {
                resultBlock([UIImage imageWithCGImage:imageRef]);
            }
        }
    } failureBlock:^(NSError *error) {
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        resultBlock(nil);
    }];
}

+ (NSString *)saveImageAtTemporaryDirectoryWithFullscreenImage:(UIImage *)fullscreenImage withCroppedImage:(UIImage *)croppedImage {
    NSData *fullscreenImageData = UIImagePNGRepresentation(fullscreenImage);
    NSData *croppedImageData = UIImagePNGRepresentation(croppedImage);
    
    NSString *filename = [@([[NSDate date] timeIntervalSince1970]) stringValue];
    NSString *fullscreenImageDirectory = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, PostfixImageFullscreen];
    NSString *croppedImageDirectory = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, PostfixImageCropped];
    
    BOOL isSaved = [fullscreenImageData writeToFile:fullscreenImageDirectory atomically:YES] && [croppedImageData writeToFile:croppedImageDirectory atomically:YES];
    
    if (isSaved) {
        return filename;
    } else {
        //하나라도 성공한 경우가 있을 수 있으므로, 이 경우를 대비하여 임시 파일 삭제 로직을 수행한다.
        [self removeTemporaryImageWithFilename:filename];
        return nil;
    }
}

+ (void)removeTemporaryImageWithFilename:(NSString *)filename {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *fullscreenImageURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, PostfixImageFullscreen]];
    NSURL *croppedImageURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, PostfixImageCropped]];
    
    [fileManager removeItemAtURL:fullscreenImageURL error:nil];
    [fileManager removeItemAtURL:croppedImageURL error:nil];
}

+ (void)removeAllTemporaryImages {
    NSFileManager *fileManage = [NSFileManager defaultManager];
    [fileManage removeItemAtPath:NSTemporaryDirectory() error:nil];
}

+ (NSURL *)generateFullscreenImageURLWithFilename:(NSString *)filename {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, PostfixImageFullscreen]];
}

+ (NSURL *)generateCroppedImageURLWithFilename:(NSString *)filename {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, PostfixImageCropped]];
}

+ (NSString *)generatePhotoFrameImageWithIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"%@%ld", PrefixImagePhotoFrame, (long)index];
}

+ (NSString *)generatePhotoFrameImageWithIndex:(NSInteger)index postfix:(NSString *)postfix {
    return [NSString stringWithFormat:@"%@%ld%@", PrefixImagePhotoFrame, (long)index, postfix];
}

@end
