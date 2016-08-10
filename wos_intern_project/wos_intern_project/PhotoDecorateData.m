//
//  PhotoDecorateData.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 30..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoDecorateData.h"

@interface PhotoDecorateData ()

@end

@implementation PhotoDecorateData

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _timestamp = @([[NSDate date] timeIntervalSince1970] * 1000);
    }
    
    return self;
}

- (instancetype)initWithTimestamp:(NSNumber *)timestamp {
    self = [super init];
    
    if (self) {
        _timestamp = timestamp;
    }
    
    return self;
}

- (UIView *)getView { return nil; }

- (void)move:(CGPoint)movePoint {
    _frame = CGRectMake(movePoint.x, movePoint.y, _frame.size.width, _frame.size.height);
}

- (void)resize:(CGRect)resizeRect {
    _frame = resizeRect;
}

- (void)rotate:(CGFloat)rotateAngle {
    _angle = rotateAngle;
}

- (void)changeZOrder {

}

@end
