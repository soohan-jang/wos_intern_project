//
//  DrawingObject.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 30..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "DrawingObject.h"

#import <CommonCrypto/CommonDigest.h>

@interface DrawingObject ()

- (NSString *)createObjectId:(NSString *)input;

@end

@implementation DrawingObject

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.z_order_timestamp = @([[NSDate date] timeIntervalSince1970]);
        self.id_hashed_timestamp = [self createObjectId:self.z_order_timestamp.stringValue];
    }
    
    return self;
}

- (void)drawInCanvasView:(UIView *)canvasView {}
- (void)containsPoint:(CGPoint)point {}
- (void)moveObject:(CGPoint)movePoint {}
- (void)resizeObject:(CGRect)resizeRect {}
- (void)rotateObject:(CGFloat)rotateAngle {}

- (NSString *)createObjectId:(NSString *)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

@end
