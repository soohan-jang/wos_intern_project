//
//  SphereMenu.h
//  SphereMenu
//
//  Created by Tu You on 14-8-24.
//  Copyright (c) 2014年 TU YOU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SphereMenuDelegate;

@interface SphereMenu : UIView

- (instancetype)initWithRootView:(UIView *)rootView Center:(CGPoint)center CloseImage:(UIImage *)image MenuImages:(NSArray *)images StartAngle:(CGFloat)startAngle;
- (void)presentMenu;
- (void)dismissMenu;

@property (nonatomic, weak) id<SphereMenuDelegate> delegate;

@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGFloat sphereDamping;
@property (nonatomic, assign) CGFloat sphereLength;

@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) NSInteger targerCellIndex;

@end

@protocol SphereMenuDelegate <NSObject>

- (void)sphereDidSelected:(SphereMenu *)sphereMenu index:(int)index targetCellIndex:(NSInteger)targetCellIndex;

@end
