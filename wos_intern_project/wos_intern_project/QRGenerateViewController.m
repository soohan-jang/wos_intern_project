//
//  QRGenerateViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "QRGenerateViewController.h"

@interface QRGenerateViewController ()

@end

@implementation QRGenerateViewController

@synthesize qrGenerateImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //QR Code 생성하여 UIImageView에 표시한다.
    qrGenerateImageView.image = [[UIImage alloc] initWithCIImage :[self generateQRCodeWithScale:@"test data" scale:5.0f]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CIImage *)generateQRCodeWithScale:(NSString *)data scale:(CGFloat)scale {
    NSData *qrCodeData = [data dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *qrCodeFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrCodeFilter setValue:qrCodeData forKey:@"inputMessage"];
    [qrCodeFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    return [qrCodeFilter.outputImage imageByApplyingTransform:transform];
}

- (BOOL)saveQRCodeImage:(UIImage *)qrcodeImage {
    return NO;
}

@end
