//
//  DrawingObject.h
//  wos_intern_project
//
//  Created by 장수한 on 2016. 7. 16..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DrawingObject : NSObject

@property (nonatomic, setter=setID:, getter=getID) NSUInteger id_hashed_timestamp;
@property (nonatomic, setter=setZOrder:, getter=getZOrder) NSUInteger z_order_timestamp;

@end
