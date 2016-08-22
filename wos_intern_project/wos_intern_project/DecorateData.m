//
//  DecorateData.ㅡ
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 30..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "DecorateData.h"

@interface DecorateData () <NSCoding>

@end

@implementation DecorateData

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    
    if (self) {
        _uuid = [NSUUID UUID];
        _timestamp = @([[NSDate date] timeIntervalSince1970] * 1000);
        _image = image;
        _frame = CGRectMake(0, 0, image.size.width, image.size.height);
        _selected = NO;
        _enabled = YES;
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image scale:(CGFloat)scale {
    self = [super init];
    
    if (self) {
        _uuid = [NSUUID UUID];
        _timestamp = @([[NSDate date] timeIntervalSince1970] * 1000);
        _image = image;
        _frame = CGRectMake(0, 0, image.size.width / scale, image.size.height / scale);
        _selected = NO;
        _enabled = YES;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        _uuid = [aDecoder decodeObjectForKey:@"_uuid"];
        _timestamp = [aDecoder decodeObjectForKey:@"_timestamp"];
        _image = [aDecoder decodeObjectForKey:@"_image"];
        _frame = [aDecoder decodeCGRectForKey:@"_frame"];
        _selected = [aDecoder decodeBoolForKey:@"_selected"];
        _enabled = [aDecoder decodeBoolForKey:@"_enabled"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_uuid forKey:@"_uuid"];
    [aCoder encodeObject:_timestamp forKey:@"_timestamp"];
    [aCoder encodeObject:_image forKey:@"_image"];
    [aCoder encodeCGRect:_frame forKey:@"_frame"];
    [aCoder encodeBool:_selected forKey:@"_selected"];
    [aCoder encodeBool:_enabled forKey:@"_enabled"];
}

- (DecorateView *)decorateView {
    DecorateView *view = [[DecorateView alloc] initWithUUID:_uuid timestamp:_timestamp];
    view.image = _image;
    view.frame = _frame;
    view.selected = _selected;
    view.enabled = _enabled;
    
    return view;
}

@end
