//
//  QRCodeUtility.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 6..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface QRCodeUtility : NSObject

/** @berif
 입력받은 data와 scale로 QR Code를 생성한다.
 Data는 내부적으로 UTF-8로 인코딩되며, scale에 따라서 크기를 조절한다. scale 값은 5.0f를 권장한다.
 scale 값이 작아지면 UIImageView의 크기에 따라 Blur 효과가 심하게 발생할 수 있다.
 */
+ (CIImage *)generateQRCodeWithScale:(NSString *) dataString scale:(CGFloat) scale;
/** @berif
 만들어진 QR Code UIImage에서 데이터를 읽어 반환한다.
 */
+ (NSString *)readQRCodeFromUIImage:(UIImage *) uiImage;
/** @berif
 만들어진 QR Code CIImage에서 데이터를 읽어 반환한다.
 */
+ (NSString *)readQRCodeFromCIImage:(CIImage *) ciImage;

- (NSString *)test:(NSNumber*)number;
- (NSString *)test:(NSString*)string number:(NSNumber*)str;

/** @berif
 만들어진 QR Code UIImage를 로컬에 저장한다.
 */
+ (BOOL)saveQRCodeWithUIImage:(UIImage *)qrcodeImage;
/** @berif
 만들어진 QR Code CIImage를 로컬에 저장한다.
 */
+ (BOOL)saveQRCodeWithCIImage:(CIImage *)qrcodeImage;



@end
