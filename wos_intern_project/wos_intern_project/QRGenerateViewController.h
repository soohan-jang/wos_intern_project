//
//  QRGenerateViewController.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface QRGenerateViewController : UIViewController

/** @berif
 생성된 QR Code가 표시될 UIImageView.
 */
@property (strong, nonatomic) IBOutlet UIImageView *qrGenerateImageView;

/** @berif
 입력받은 data와 scale로 QR Code를 생성한다.
 Data는 내부적으로 UTF-8로 인코딩되며, scale에 따라서 크기를 조절한다. scale 값은 5.0f를 권장한다.
 scale 값이 작아지면 UIImageView의 크기에 따라 Blur 효과가 심하게 발생할 수 있다.
 */
- (CIImage *)generateQRCodeWithScale:(NSString *)data scale:(CGFloat)scale;
/** @berif
 만들어진 QR Code Image를 로컬에 저장한다.
 */
- (BOOL)saveQRCodeImage:(UIImage *)qrcodeImage;

@end
