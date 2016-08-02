//
//  UIView+StringTag.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 2..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "UIView+StringTag.h"

@implementation UIView (StringTag)

static NSString *stringTagKey = @"stringTag";

- (NSString *)stringTag {
    return objc_getAssociatedObject(self, CFBridgingRetain(stringTagKey));
}

- (void)setStringTag:(NSString *)stringTag {
    objc_setAssociatedObject(self, CFBridgingRetain(stringTagKey), stringTag, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
