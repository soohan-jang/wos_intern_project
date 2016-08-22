//
//  ProgressHelper.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 8..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "WMProgressHUD.h"

typedef NS_ENUM(NSInteger, ProgressDismissType) {
    DismissWithDone     = 0,
    DismissWithCancel   = 1
};

@interface ProgressHelper : NSObject

/**
 @berif
 ProgressHUD가 추가될 뷰와 title로 사용할 NSLocalizedString Key를 파라메터로 받아 ProgressHUD를 표시한다.
 */
+ (WMProgressHUD *)showProgressAddedTo:(UIView *)view titleKey:(NSString *)titleKey;

/**
 @berif
 ProgressHUD의 타이틀과 이미지를 변경하고, 정의된 DelayTime 후에 ProgressHUD를 제거한다.
 */
+ (void)dismissProgress:(WMProgressHUD *)progress dismissTitleKey:(NSString *)dismissTitleKey dismissType:(NSInteger)type;

/**
 @berif
 ProgressHUD를 즉시 사라지게 한다.
 */
+ (void)dismissProgress:(WMProgressHUD *)progress;

@end
