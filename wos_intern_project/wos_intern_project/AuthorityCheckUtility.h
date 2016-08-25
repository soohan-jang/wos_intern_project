//
//  AuthorityCheckUtility.h
//  wos_intern_project
//
//  Created by Naver on 2016. 8. 8..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthorityCheckUtility : NSObject

+ (BOOL)checkPhotoAlbumAccessAuthority;
+ (BOOL)checkPhotoCameraAccessAuthority;

@end
