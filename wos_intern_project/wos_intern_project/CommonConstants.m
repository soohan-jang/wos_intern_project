//
//  CommonConstants.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 3..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "CommonConstants.h"

/** MCSession Service Type **/
/** 이 값이 일치하는 장비만 Bluetooth 장비목록에 노출된다 **/
NSString *const ApplicationBluetoothServiceType         = @"Co-PhotoEditor";

NSString *const PrefixImagePhotoFrame                   = @"PhotoFrame";
NSString *const PostfixImageFullscreen                  = @"_fullscreen";
NSString *const PostfixImageCropped                     = @"_cropped";
NSString *const SperatorImageName                       = @"+";

NSString *const SegueMoveToAlbum                        = @"moveToPhotoAlbum";
NSString *const SegueMoveToFrameSelect                  = @"moveToPhotoFrameSelect";
NSString *const SegueMoveToEditor                       = @"moveToPhotoEditor";
NSString *const SegueMoveToCropper                      = @"moveToPhotoCrop";

NSString *const ReuseCellFrameSlt                       = @"frameSelectCell";
NSString *const ReuseCellEditor                         = @"photoFrameCell";

NSInteger const DelayTime                               = 1;