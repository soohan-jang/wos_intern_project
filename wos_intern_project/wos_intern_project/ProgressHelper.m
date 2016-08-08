//
//  ProgressHelper.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 8..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "ProgressHelper.h"

float const ProgressDefaultDelayTime = 1.0f;

@implementation ProgressHelper

+ (WMProgressHUD *)showProgressAddedTo:(UIView *)view titleKey:(NSString *)titleKey {
    return [WMProgressHUD showHUDAddedTo:view animated:YES title:NSLocalizedString(titleKey, nil)];
}

+ (void)dismissProgress:(WMProgressHUD *)progress dismissTitleKey:(NSString *)dismissTitleKey dismissType:(NSInteger)type {
    if (!progress || progress.isHidden)
        return;
    
    UIImage *image;
    
    switch (type) {
        case DismissWithDone:
            image = [UIImage imageNamed:@"Checkmark"];
            break;
        case DismissWithCancel:
            image = [UIImage imageNamed:@"Cancelmark"];
            break;
    }
    
    [progress dismissProgressWithTitle:NSLocalizedString(dismissTitleKey, nil) image:image delay:ProgressDefaultDelayTime];
}

+ (void)dismissProgress:(WMProgressHUD *)progress {
    [progress dismissProgress];
}

@end
