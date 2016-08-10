//
//  AlertHelper.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 4..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AlertStyle) {
    AlertStyleButtonNone    = 0,
    AlertStyleButtonOne     = 1,
    AlertStyleButtonTwo     = 2
};

@interface AlertHelper : NSObject

+ (void)showAlertControllerOnViewController:(UIViewController * _Nonnull)viewController
                                      title:(NSString * __nullable)title
                                    message:(NSString * __nullable)message
                                firstButton:(UIAlertAction * __nullable)firstButton
                               secondButton:(UIAlertAction * __nullable)secondButton;

+ (void)showAlertControllerOnViewController:(UIViewController * _Nonnull)viewController
                                   titleKey:(NSString * __nullable)titleKey
                                 messageKey:(NSString * __nullable)messageKey
                                firstButton:(UIAlertAction * __nullable)firstButton
                               secondButton:(UIAlertAction * __nullable)secondButton;

+ (UIAlertAction * _Nonnull)createActionWithTitleKey:(NSString * _Nonnull)titleKey
                                             handler:(void (^ __nullable)(UIAlertAction  * _Nonnull action))handler;

@end
