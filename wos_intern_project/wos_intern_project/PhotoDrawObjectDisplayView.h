//
//  PhotoDrawObjectDisplayView.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 1..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DecorateObjectManager.h"

#import "WMPhotoDecorateObject.h"
#import "WMPhotoDecorateImageObject.h"
#import "WMPhotoDecorateTextObject.h"

@protocol PhotoDrawObjectDisplayViewDelegate;

@interface PhotoDrawObjectDisplayView : UIView

@property (nonatomic, weak) id<PhotoDrawObjectDisplayViewDelegate> delegate;

- (void)addDrawObject:(WMPhotoDecorateObject *)drawObject;
- (void)updateDrawObject:(WMPhotoDecorateObject *)drawObject;
- (void)removeDrawObjectWithID:(NSString *)identifier;
- (void)sortDrawObject;

@end

@protocol PhotoDrawObjectDisplayViewDelegate <NSObject>
@required
- (void)drawObjectDidMoved:(WMPhotoDecorateObject *)decoObject;
- (void)drawObjectDidResized:(WMPhotoDecorateObject *)decoObject;
- (void)drawObjectDidRotate:(WMPhotoDecorateObject *)decoObject;
- (void)drawObjectDidDelete:(WMPhotoDecorateObject *)decoObject;

@end