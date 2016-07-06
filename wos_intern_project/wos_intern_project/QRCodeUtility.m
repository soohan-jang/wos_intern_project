//
//  QRCodeUtility.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 6..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "QRCodeUtility.h"

@implementation QRCodeUtility

+ (CIImage *)generateQRCodeWithScale:(NSString *)dataString scale:(CGFloat)scale {
    NSData *qrCodeData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *qrCodeFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrCodeFilter setValue:qrCodeData forKey:@"inputMessage"];
    [qrCodeFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    return [qrCodeFilter.outputImage imageByApplyingTransform:transform];
}

+ (NSString *)readQRCodeFromUIImage:(UIImage *)uiImage {
    return nil;
}

+ (NSString *)readQRCodeFromCIImage:(CIImage *)ciImage {
    return nil;
}

+ (BOOL)saveQRCodeWithUIImage:(UIImage *)qrcodeImage {
    return NO;
}

+ (BOOL)saveQRCodeWithCIImage:(CIImage *)qrcodeImage {
    return NO;
}

@end
