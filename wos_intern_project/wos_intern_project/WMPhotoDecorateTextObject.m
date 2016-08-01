//
//  WMPhotoDecorateTextObject.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "WMPhotoDecorateTextObject.h"

@interface WMPhotoDecorateTextObject ()

@end

@implementation WMPhotoDecorateTextObject

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    
    if (self) {
        self.text = text;
    }
    
    return self;
}

- (instancetype)initWithText:(NSString *)text WithID:(NSString *)identifier {
    self = [super init];
    
    if (self) {
        self.id_hashed_timestamp = [self createObjectId:identifier];
        self.text = text;
    }
    
    return self;
}

- (instancetype)initWithText:(NSString *)text WithTimestamp:(NSNumber *)timestamp {
    self = [super initWithTimestamp:timestamp];
    
    if (self) {
        self.text = text;
    }
    
    return self;
}

- (id)getData {
    return self.text;
}

- (UIView *)getView {
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = self.text;
    textLabel.frame = self.frame;
    //이 시점에서 텍스트 길이와 크기를 계산하여 라벨의 너비와 높이를 할당해주어야 한다.
    return textLabel;
}

- (void)containsPoint:(CGPoint)point {}
- (void)moveObject:(CGPoint)movePoint {}
- (void)resizeObject:(CGRect)resizeRect {}
- (void)rotateObject:(CGFloat)rotateAngle {}

@end
