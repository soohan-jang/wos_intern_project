//
//  QRGenerateViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRGenerateViewController : UIViewController

/** @berif
 생성된 QR Code가 표시될 UIImageView.
 */
@property (strong, nonatomic) IBOutlet UIImageView *qrGenerateImageView;

/** @berif
 QR Code를 읽는 화면(전화면)으로 돌아간다.
 */
- (IBAction)backAction:(id)sender;

@end
