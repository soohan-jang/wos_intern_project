//
//  ImageUtility.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 23..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "ImageUtility.h"

NSInteger const IMAGE_RESIZE_THUMBNAIL = 90;
NSInteger const IMAGE_RESIZE_STANDARD  = 640;

NSString *const FILE_POSTFIX_THUMBNAIL = @"_thumbnail";
NSString *const FILE_POSTFIX_STANDARD  = @"_standard";

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

- (BOOL)makeTempImageWithAssetRepresentation:(ALAssetRepresentation *) representation {
    Byte *buffer = (Byte *)malloc((unsigned long)representation.size);
    NSInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:(unsigned long)representation.size error:nil];
    
    NSData *tempData = [NSData dataWithBytesNoCopy:buffer length:buffered];
    NSString *filename = representation.filename;
    NSString *directory = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), filename];
    
    
    return [tempData writeToFile:directory atomically:YES];
}

- (BOOL)makeTempImageWithFilename:(NSString *)filename resizeOption:(NSInteger)option {
    if (option != IMAGE_RESIZE_THUMBNAIL && option != IMAGE_RESIZE_STANDARD)
        return NO;
    
    NSString *originDir = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), filename];
    NSURL *fileURL = [NSURL fileURLWithPath:originDir];
    
    if (fileURL == nil)
        return NO;
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)fileURL, NULL);
    CFDictionaryRef options = (__bridge CFDictionaryRef) @{(id) kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                           (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                           (id) kCGImageSourceThumbnailMaxPixelSize : @(option)};
    CGImageRef imgRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options);
    UIImage *resizedImage = [UIImage imageWithCGImage:imgRef];
    
    CGImageRelease(imgRef);
    CFRelease(imageSource);

    //파일 전송을 위해 리사이즈된 이미지를 임시로 저장한다.
    NSData *resizedData = UIImagePNGRepresentation(resizedImage);
    NSString *directory = nil;
    
    if (option == IMAGE_RESIZE_THUMBNAIL) {
        directory = [NSString stringWithFormat:@"%@%@_thumbnail", NSTemporaryDirectory(), filename];
    }
    else if (option == IMAGE_RESIZE_STANDARD) {
        directory = [NSString stringWithFormat:@"%@%@_standard", NSTemporaryDirectory(), filename];
    }
    
    return [resizedData writeToFile:directory atomically:YES];
}

- (void)removeTempImageWithFilename:(NSString *)filename {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *originalURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), filename]];
    NSURL *thumbnailURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_thumbnail", NSTemporaryDirectory(), filename]];
    NSURL *standardURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_standard", NSTemporaryDirectory(), filename]];
    
    [fileManager removeItemAtURL:originalURL error:nil];
    [fileManager removeItemAtURL:thumbnailURL error:nil];
    [fileManager removeItemAtURL:standardURL error:nil];
}

- (void)removeAllTempImages {
    NSFileManager *fileManage = [NSFileManager defaultManager];
    [fileManage removeItemAtPath:NSTemporaryDirectory() error:nil];
}

@end
