//
//  ProgressHelper.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 8..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "ProgressHelper.h"
#import "CommonConstants.h"
#import "DispatchAsyncHelper.h"

@implementation ProgressHelper

+ (WMProgressHUD *)showProgressAddedTo:(UIView *)view titleKey:(NSString *)titleKey {
    return [WMProgressHUD showHUDAddedTo:view animated:YES title:NSLocalizedString(titleKey, nil)];
}

+ (void)dismissProgress:(WMProgressHUD *)progress dismissTitleKey:(NSString *)dismissTitleKey dismissType:(NSInteger)type {
    [ProgressHelper dismissProgress:progress
                    dismissTitleKey:dismissTitleKey
                        dismissType:type
                  completionHandler:nil];
}

+ (void)dismissProgress:(WMProgressHUD *)progress dismissTitleKey:(NSString *)dismissTitleKey dismissType:(NSInteger)type completionHandler:(void(^)(void))completionHandler {
    if (!progress || progress.isHidden) {
        return;
    }
    
    UIImage *image;
    
    switch (type) {
        case DismissWithDone:
            image = [UIImage imageNamed:@"Checkmark"];
            break;
        case DismissWithCancel:
            image = [UIImage imageNamed:@"Cancelmark"];
            break;
    }
    
    __weak typeof(progress) weakProgress = progress;
    [DispatchAsyncHelper dispatchAsyncWithBlockOnMainQueue:^{
        __strong typeof(weakProgress) progress = weakProgress;
        
        if (!progress) {
            return;
        }
        
        [progress dismissProgressWithTitle:NSLocalizedString(dismissTitleKey, nil) image:image delay:DelayTime];
        
        if (!completionHandler) {
            return;
        }
        
        [NSTimer scheduledTimerWithTimeInterval:DelayTime
                                         target:self
                                       selector:@selector(completionHandler)
                                       userInfo:nil
                                        repeats:NO];
    }];
}

+ (void)dismissProgress:(WMProgressHUD *)progress {
    __weak typeof(progress) weakProgress = progress;
    [DispatchAsyncHelper dispatchAsyncWithBlockOnMainQueue:^{
        __strong typeof(weakProgress) progress = weakProgress;
        
        if (!progress) {
            return;
        }
        
        [progress dismissProgress];
    }];
}

@end
