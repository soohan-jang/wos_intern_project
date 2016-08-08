//
//  WMProgressHUD.h
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 14..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MBProgressHUD.h"

@interface WMProgressHUD : MBProgressHUD

/**
 ProgressHUD를 화면에 보여준다. ProgressHUD가 위치할 부모 View, 애니메이팅 여부, 타이틀을 인자로 받는다.
 */
+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated title:(NSString *)title;

/**
 ProgressHUD를 화면에 보여준다. ProgressHUD가 위치할 부모 View, 애니메이팅 여부, 타이틀, 디테일한 내용을 인자로 받는다.
 */
+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated title:(NSString *)title detail:(NSString *)detail;

/**
 @berif
 화면에 표시된 ProgressHUD를 title, image로 변경하고 delay가 지난 이후에 사라지게 한다.
 */
- (void)dismissProgressWithTitle:(NSString *)title image:(UIImage *)image delay:(NSTimeInterval)delay;

/**
 화면에 표시된 ProgressHUD를 즉시 사라지게 한다..
 */
- (void)dismissProgress;

@end