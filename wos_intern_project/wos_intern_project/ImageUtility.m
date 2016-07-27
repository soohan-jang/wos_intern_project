//
//  ImageUtility.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 23..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "ImageUtility.h"

NSString *const FILE_POSTFIX_CROPPED     = @"_cropped";
NSString *const FILE_POSTFIX_FULLSCREEN  = @"_fullscreen";

@implementation ImageUtility

+ (ImageUtility *)sharedInstance {
    static ImageUtility *instance = nil;
    
    @synchronized (self) {
        if (instance == nil) {
            instance = [[ImageUtility alloc] init];
        }
    }
    
    return instance;
}

- (void)getFullScreenUIImageWithURL:(NSURL *)url resultBlock:(ImageUtilityForGetFullScreenImageBlock)resultBlock {
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    
    [assetslibrary assetForURL:url resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        resultBlock([UIImage imageWithCGImage:representation.fullScreenImage]);
    } failureBlock:^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

//for dummy data.
- (NSString *)saveImageAtTemporaryDirectoryForDummy:(UIImage *)image {
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSString *filename = [@([[NSDate date] timeIntervalSince1970]) stringValue];
    NSString *directory = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), filename];
    
    BOOL isSaved = [imageData writeToFile:directory atomically:YES];
    
    if (isSaved) {
        return filename;
    }
    else {
        return nil;
    }
}

- (NSString *)saveImageAtTemporaryDirectoryWithFullscreenImage:(UIImage *)fullscreenImage croppedImage:(UIImage *)croppedImage {
    NSData *fullscreenImageData = UIImagePNGRepresentation(fullscreenImage);
    NSData *croppedImageData = UIImagePNGRepresentation(croppedImage);
    
    NSString *filename = [@([[NSDate date] timeIntervalSince1970]) stringValue];
    NSString *fullscreenImageDirectory = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, FILE_POSTFIX_FULLSCREEN];
    NSString *croppedImageDirectory = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, FILE_POSTFIX_CROPPED];
    
    BOOL isSaved = [fullscreenImageData writeToFile:fullscreenImageDirectory atomically:YES] && [croppedImageData writeToFile:croppedImageDirectory atomically:YES];
    
    if (isSaved) {
        return filename;
    }
    else {
        //하나라도 성공한 경우가 있을 수 있으므로, 이 경우를 대비하여 임시 파일 삭제 로직을 수행한다.
        [self removeTempImageWithFilename:filename];
        return nil;
    }
}

- (void)removeTempImageWithFilename:(NSString *)filename {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *fullscreenImageURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, FILE_POSTFIX_FULLSCREEN]];
    NSURL *croppedImageURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, FILE_POSTFIX_CROPPED]];
    
    [fileManager removeItemAtURL:fullscreenImageURL error:nil];
    [fileManager removeItemAtURL:croppedImageURL error:nil];
}

- (void)removeAllTempImages {
    NSFileManager *fileManage = [NSFileManager defaultManager];
    [fileManage removeItemAtPath:NSTemporaryDirectory() error:nil];
}

- (NSURL *)getFullscreenImageURLWithFilename:(NSString *)filename {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, FILE_POSTFIX_FULLSCREEN]];
}

- (NSURL *)getCroppedImageURLWithFilename:(NSString *)filename {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), filename, FILE_POSTFIX_CROPPED]];
}

@end
