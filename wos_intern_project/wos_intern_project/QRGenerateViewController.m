//
//  QRGenerateViewController.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "QRGenerateViewController.h"
#import "QRCodeUtility.h"

@interface QRGenerateViewController ()

@end

@implementation QRGenerateViewController

@synthesize qrGenerateImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //QR Code 생성하여 UIImageView에 표시한다.
    qrGenerateImageView.image = [[UIImage alloc] initWithCIImage :[QRCodeUtility generateQRCodeWithScale:@"test data" scale:5.0f]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
}
@end
