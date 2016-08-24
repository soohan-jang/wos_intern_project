//
//  MessageData.m
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 22..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "MessageData.h"

@interface MessageData () <NSCoding>

@end

@implementation MessageData

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        _messageType = [aDecoder decodeIntegerForKey:@"_messageType"];
        _messageTimestamp = [aDecoder decodeDoubleForKey:@"_messageTimestamp"];
        
        _inviteAck = [aDecoder decodeBoolForKey:@"_inviteAck"];
        
        _photoFrameIndexPath = [aDecoder decodeObjectForKey:@"_photoFrameIndexPath"];
        _photoFrameConfirmAck = [aDecoder decodeBoolForKey:@"_photoFrameConfirmAck"];
        
        _deviceDataScreenSize = [aDecoder decodeCGSizeForKey:@"_deviceDataScreenSize"];
        
        _photoDataIndexPath = [aDecoder decodeObjectForKey:@"_photoDataIndexPath"];
        _photoDataRecevieAck = [aDecoder decodeBoolForKey:@"_photoDataRecevieAck"];
        
        _decorateDataUUID = [aDecoder decodeObjectForKey:@"_decorateDataUUID"];
        _decorateData = [aDecoder decodeObjectForKey:@"_decorateData"];
        _decorateDataFrame = [aDecoder decodeCGRectForKey:@"_decorateDataFrame"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_messageType forKey:@"_messageType"];
    [aCoder encodeDouble:_messageTimestamp forKey:@"_messageTimestamp"];
    
    [aCoder encodeBool:_inviteAck forKey:@"_inviteAck"];
    
    [aCoder encodeObject:_photoFrameIndexPath forKey:@"_photoFrameIndexPath"];
    [aCoder encodeBool:_photoFrameConfirmAck forKey:@"_photoFrameConfirmAck"];
    
    [aCoder encodeCGSize:_deviceDataScreenSize forKey:@"_deviceDataScreenSize"];
    
    [aCoder encodeObject:_photoDataIndexPath forKey:@"_photoDataIndexPath"];
    [aCoder encodeBool:_photoDataRecevieAck forKey:@"_photoDataRecevieAck"];
    
    [aCoder encodeObject:_decorateDataUUID forKey:@"_decorateDataUUID"];
    [aCoder encodeObject:_decorateData forKey:@"_decorateData"];
    [aCoder encodeCGRect:_decorateDataFrame forKey:@"_decorateDataFrame"];
}

@end
