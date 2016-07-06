//
//  QRCodeCaptureMetadataOutputObjectsDelegate.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 6..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@protocol QRCodeCaptureMetadataOutputObjectsDelegate <AVCaptureMetadataOutputObjectsDelegate>

- (void) stopQRCodeReadSelector:(id)selector;

@end