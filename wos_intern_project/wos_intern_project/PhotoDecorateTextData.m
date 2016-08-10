//
//  PhotoDecorateTextData.m
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "PhotoDecorateTextData.h"

@implementation PhotoDecorateTextData

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    
    if (self) {
        self.data = text;
    }
    
    return self;
}

- (instancetype)initWithText:(NSString *)text timestamp:(NSNumber *)timestamp {
    self = [super initWithTimestamp:timestamp];
    
    if (self) {
        self.data = text;
    }
    
    return self;
}

- (UIView *)getView {
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = self.data;
    textLabel.frame = self.frame;
    //이 시점에서 텍스트 길이와 크기를 계산하여 라벨의 너비와 높이를 할당해주어야 한다.
    return textLabel;
}

@end
