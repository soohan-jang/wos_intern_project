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
 ProgressHUD를 화면에 보여준다. ProgressHUD가 위치할 부모 View, 애니메이팅 여부, 타이틀, 디테일한 내용, 투명도를 인자로 받는다.
 */
//+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated title:(NSString *)title detail:(NSString *)detail alpha:(CGFloat)alpha;

/**
 화면에 표시된 ProgressHUD의 상태를 완료로 변경하고, 일정시간 뒤 화면에서 사라지게 한다. ProgressHUD에 표시될 완료 문구, 사라지기 까지의 딜레이를 인자로 받는다.
 */
- (void)doneProgressWithTitle:(NSString *)title delay:(NSTimeInterval)delay;

/**
 화면에 표시된 ProgressHUD의 상태를 완료로 변경하고, 일정시간 뒤 화면에서 사라지게 한다. ProgressHUD에 표시될 완료 문구, 사라지기 까지의 딜레이를 인자로 받는다.
 취소된 경우에는 checkmark가 아닌 cancelmark를 표시하게 할 수 있다. 이를 위해 canceled 값에 YES를 주면된다.
 */
- (void)doneProgressWithTitle:(NSString *)title delay:(NSTimeInterval)delay cancel:(BOOL)canceled;

/**
 화면에 표시된 ProgressHUD를 즉시 사라지게 만든다.
 */
- (void)dismissProgress;

@end
