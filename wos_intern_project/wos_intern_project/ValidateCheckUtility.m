//
//  ValidateCheckUtility.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 8..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "ValidateCheckUtility.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@implementation ValidateCheckUtility

#pragma mark - Authority & Validate Check Methods

/**
 포토 앨범 접근 권한을 가지고 있는지 확인한다. 아직 권한이 설정되지 않았거나, 권한을 가졌다면 YES를 반환하고, 아니라면 NO를 반환한다.
 */
+ (BOOL)checkPhotoAlbumAccessAuthority {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if (!status) {
        return NO;
    }
    
    if (status == ALAuthorizationStatusNotDetermined || status == ALAuthorizationStatusAuthorized) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)checkPhotoCameraAccessAuthority {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (!status) {
        return NO;
    }
    
    if (status == AVAuthorizationStatusNotDetermined || status == AVAuthorizationStatusAuthorized) {
        return YES;
    }
    
    return NO;
}

@end
