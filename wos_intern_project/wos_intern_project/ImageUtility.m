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

+ (UIImage *)resizeImage:(UIImage *)image {
    CGFloat scale = [UIScreen mainScreen].scale * 3;
    CGRect resizeRect = CGRectMake(0, 0, image.size.width / scale, image.size.height / scale);
    
    UIGraphicsBeginImageContext(resizeRect.size);
    [image drawInRect:resizeRect];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

+ (void)fullscreenImageAtURL:(NSURL *)url resultBlock:(ImageUtilityForGetFullScreenImageBlock)resultBlock {
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

+ (void)saveImageAtPhotoAlbum:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

+ (NSString *)saveImageAtTemporaryDirectoryWithFullscreenImage:(UIImage *)fullscreenImage withCroppedImage:(UIImage *)croppedImage {
    NSData *fullscreenImageData = UIImagePNGRepresentation(fullscreenImage);
    NSData *croppedImageData = UIImagePNGRepresentation(croppedImage);
    
    NSString *filename = [@([[NSDate date] timeIntervalSince1970]) stringValue];
    NSString *fullscreenImageDirectory = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, IdentifierImageOriginal];
    NSString *croppedImageDirectory = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, IdentifierImageCropped];
    
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
    
    NSURL *fullscreenImageURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, IdentifierImageOriginal]];
    NSURL *croppedImageURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, IdentifierImageCropped]];
    
    [fileManager removeItemAtURL:fullscreenImageURL error:nil];
    [fileManager removeItemAtURL:croppedImageURL error:nil];
}

+ (void)removeAllTemporaryImages {
    NSFileManager *fileManage = [NSFileManager defaultManager];
    [fileManage removeItemAtPath:NSTemporaryDirectory() error:nil];
}

+ (NSURL *)fullscreenImageURLWithFilename:(NSString *)filename {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, IdentifierImageOriginal]];
}

+ (NSURL *)croppedImageURLWithFilename:(NSString *)filename {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, IdentifierImageCropped]];
}

NSString *const PrefixImagePhotoFrame   = @"PhotoFrame";

+ (NSString *)photoFrameImageWithIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"%@%ld", PrefixImagePhotoFrame, (long)index];
}

NSString *const PrefixImagePhotoSticker = @"PhotoSticker";

+ (NSString *)photoStickerImageWithIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"%@%ld", PrefixImagePhotoSticker, (long)index];
}

+ (UIImage *)coloredImageNamed:(NSString *)imageName color:(UIColor *)color {
    UIImage *image = [UIImage imageNamed:imageName];
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *coloredImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0
                                          orientation:UIImageOrientationDownMirrored];
    
    return coloredImage;
}

CGFloat const CaptureScale = 4.0f;

+ (UIImage *)viewCaptureImage:(UIView *)view {
    CGRect bounds = CGRectMake(view.bounds.origin.x,
                               view.bounds.origin.y,
                               view.bounds.size.width * CaptureScale,
                               view.bounds.size.height * CaptureScale);
    
    UIGraphicsBeginImageContext(bounds.size);
    [view drawViewHierarchyInRect:bounds afterScreenUpdates:YES];
    UIImage *canvasViewCaptureImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([canvasViewCaptureImage CGImage], bounds);
    UIImage *captureImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    return captureImage;
}

+ (UIImage *)mergeImage:(UIImage *)imageA imageB:(UIImage *)imageB {
    CGRect bounds = CGRectMake(0, 0, imageA.size.width, imageA.size.height);
    
    UIGraphicsBeginImageContext(imageA.size);
    [imageA drawInRect:bounds];
    [imageB drawInRect:CGRectIntegral(bounds)];
    UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return mergedImage;
}

@end
