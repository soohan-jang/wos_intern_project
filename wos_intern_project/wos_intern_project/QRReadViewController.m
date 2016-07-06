//
//  QRReadViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "QRReadViewController.h"
#import "QRCodeUtility.h"

#define QRCODE_DISPATCH_QUEUE   "qrCode_dispatch_queue"

@interface QRReadViewController ()

@end

@implementation QRReadViewController

@synthesize qrCodeReadPreview, qrCodeDataDisplay_test, isReaderActivate, captureSession, captureVideoPreviewLayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isReaderActivate = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    //QR Code Reader를 활성화시킨다.
    [self startQRCodeRead];
}

- (void)viewWillDisappear:(BOOL)animated {
    //다른 ViewController로 전환될 때 QR Code Reader를 비활성화 시킨다.
    //prepareSegue로 이동시켜야 하나? 테스트 필요할 것으로 보인다.
    [self stopQRCodeRead];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)startQRCodeRead {
    NSError *error;
    
    //Get capture device and set input & output
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    if (captureDeviceInput == nil) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    //Session alloc, add input & output
    captureSession = [[AVCaptureSession alloc] init];
    [captureSession addInput:captureDeviceInput];
    [captureSession addOutput:captureMetadataOutput];
    
    //QR Code Metadata를 읽고 처리할 델리게이트 디스패치 큐를 만들고, output에 할당한다. output으로 처리할 metadata를 QR Code로 설정한다.
    dispatch_queue_t qrCodeDispatchQueue = dispatch_queue_create(QRCODE_DISPATCH_QUEUE, NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:qrCodeDispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [captureVideoPreviewLayer setFrame:qrCodeReadPreview.layer.bounds];
    
    [qrCodeReadPreview.layer addSublayer:captureVideoPreviewLayer];
    
    [captureSession startRunning];
    
    isReaderActivate = YES;
    
    return YES;
}

- (BOOL)stopQRCodeRead {
    [captureSession stopRunning];
    [captureVideoPreviewLayer removeFromSuperlayer];
    
    captureSession = nil;
    
    captureVideoPreviewLayer = nil;
    isReaderActivate = NO;
    
    return YES;
}

- (IBAction)loadAlbumAction:(id)sender {
    
}

//이런 식으로 구현을 해서 포인터를 전달해보자.
- (void)stopQRCodeReadSelector:(id)selector {
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            //QR Code Reading Success. Stop Reading, goto other view controller.
            NSLog(@"%@", [metadataObject stringValue]);
            //UILabel에 임시로 읽은 데이터를 표시한다. UI Thread에 접근하기 위하여 performSelectorOnMainThread를 사용한다.
            [qrCodeDataDisplay_test performSelectorOnMainThread:@selector(setText:) withObject:[metadataObject stringValue] waitUntilDone:NO];
            //아래의 코드가 동작을 하는지 안하는지 확인 필요.
            //[self stopQRCodeRead];
            //실제로 델리게이트가 설정된 디스패치 큐를 활용한 쓰레드로 작업되므로, 쓰레드 내부에서 다른 쓰레드로 접근하기 위해 performSelector를 써서 위임을 하는 것 같다. 이 부분은 확인이 필요하다.
            //최근에는 지양하는 방법. UI를 변경하기 위해 MainThread에 접근하는 건 방법이 없다. 그게 아닌 경우에는 메소드 포인터를 Thread에 넘겨 performSelector 대신에 사용한다.
            [self performSelector:@selector(stopQRCodeRead)];
            
            //위의 내용을 구현하기 위해서는... 일단 지금의 생각으로는 delegate를 상속받은 protocol을 만든 뒤에, 해당 protocol 내부에 메소드 포인터를 넘겨주는 방법을 사용하면 될 것 같다.
        }
    }
}

@end
