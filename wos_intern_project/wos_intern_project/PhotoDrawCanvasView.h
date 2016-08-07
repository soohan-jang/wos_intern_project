//
//  PhotoDrawCanvasView.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 8. 6..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, Mode) {
    ModeDraw    = 0,
    ModeErase   = 1
};

@interface PhotoDrawCanvasView : UIView

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) NSInteger drawMode;

- (UIImage *)getPathImage;
- (void)clear;

@end
