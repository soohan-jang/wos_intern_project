//
//  WMPhotoDecorateObject.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 30..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "WMPhotoDecorateObject.h"
#import <CommonCrypto/CommonDigest.h>

@interface WMPhotoDecorateObject ()

@end

@implementation WMPhotoDecorateObject

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.z_order_timestamp = @([[NSDate date] timeIntervalSince1970]);
        self.id_hashed_timestamp = [self createObjectId:self.z_order_timestamp.stringValue];
    }
    
    return self;
}

- (instancetype)initWithTimestamp:(NSNumber *)timestamp {
    self = [super init];
    
    if (self) {
        self.z_order_timestamp = timestamp;
        self.id_hashed_timestamp = [self createObjectId:self.z_order_timestamp.stringValue];
    }
    
    return self;
}

- (UIView *)getView { return nil; }

- (void)moveObject:(CGPoint)movePoint {
    self.frame = CGRectMake(movePoint.x, movePoint.y, self.frame.size.width, self.frame.size.height);
}

- (void)resizeObject:(CGSize)resizeRect {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, resizeRect.width, resizeRect.height);
}

- (void)rotateObject:(CGFloat)rotateAngle {
    self.angle = rotateAngle;
}

- (void)changeZOrder:(NSInteger)zOrder {}

- (NSString *)createObjectId:(NSString *)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

@end
