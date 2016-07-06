//
//  QRReadViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCodeCaptureMetadataOutputObjectsDelegate.h"

@interface QRReadViewController : UIViewController <QRCodeCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) IBOutlet UIView *qrCodeReadPreview;
@property (strong, nonatomic) IBOutlet UILabel *qrCodeDataDisplay_test;

@property (nonatomic) BOOL isReaderActivate;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

/** berif
 capture session을 열고, QR Code 읽어들이는 작업을 시작한다.
 */
- (BOOL)startQRCodeRead;
/** berif
 capture session을 닫고, QR Code 읽어들이는 작업을 종료한다.
 */
- (BOOL)stopQRCodeRead;
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection;

/** @berif
 디바이스의 카메라롤을 열고, 사진 정보를 가져오는건데... 어쨌든 그런식으로 구현할 예정.
 */
- (IBAction)loadAlbumAction:(id)sender;

@end
