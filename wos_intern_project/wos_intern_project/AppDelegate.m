//
//  AppDelegate.m
//  wos_intern_project
//
//  Created by Naver on 2016. 7. 5..
//  Copyright © 2016년 worksmobile. All rights reserved.
//

#import "AppDelegate.h"
#import "ConnectionManager.h"
#import "ImageUtility.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

// Override point for customization after application launch.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[ConnectionManager sharedInstance] disconnectSession];
    return YES;
}

// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
- (void)applicationWillResignActive:(UIApplication *)application {
}

// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
- (void)applicationDidEnterBackground:(UIApplication *)application {
}

// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
- (void)applicationWillEnterForeground:(UIApplication *)application {
}

// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
- (void)applicationDidBecomeActive:(UIApplication *)application {
}

// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
- (void)applicationWillTerminate:(UIApplication *)application {
    [self clearResources];
}

//Crash 발생하여 강제적으로 종료될 될 때, 세션을 정리하기 위하여 사용한다.
//내부에서 clearResources를 호출하면 되는데, 어떻게 호출하나?
void uncaughtExceptionHandler(NSException *exception) {
    //세션 종료 시, 커넥션매니저와 메시지큐를 정리한다.
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    connectionManager.sessionDelegate = nil;
    
    connectionManager.photoFrameControlDelegate = nil;
    connectionManager.photoFrameDataDelegate = nil;
    
    connectionManager.photoEditorDelegate = nil;
    
    connectionManager.messageQueueEnabled = NO;
    [connectionManager disconnectSession];
    [connectionManager clear];
    
    //사용된 임시 파일을 정리한다.
    [ImageUtility removeAllTemporaryImages];
}

- (void)clearResources {
    //세션 종료 시, 커넥션매니저와 메시지큐를 정리한다.
    ConnectionManager *connectionManager = [ConnectionManager sharedInstance];
    connectionManager.sessionDelegate = nil;
    
    connectionManager.photoFrameControlDelegate = nil;
    connectionManager.photoFrameDataDelegate = nil;
    
    connectionManager.photoEditorDelegate = nil;
    
    connectionManager.messageQueueEnabled = NO;
    [connectionManager disconnectSession];
    [connectionManager clear];
    
    //사용된 임시 파일을 정리한다.
    [ImageUtility removeAllTemporaryImages];
}

@end
