/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "AppDelegate.h"

@implementation AppDelegate

-(void) initializationComplete
{
#ifdef KK_ARC_ENABLED
	CCLOG(@"ARC is enabled");
#else
	CCLOG(@"ARC is either not available or not enabled");
#endif
    [MGWU loadMGWU:@"mvd4c1mvd4c1"];
	
    [MGWU preFacebook];
    [MGWU dark];
	
	[MGWU setReminderMessage:@"Alien spaceships are attacking, defend now!"];
	
	[MGWU setTapjoyAppId: @"376b659e-8e91-4a7c-a2ff-ec63dba6b474" andSecretKey:@"vnraa5XlnSSSNjt3vmt8"];
	
	[MGWU setAppiraterAppId:@"649608211" andAppName:@"Space Breakers"];
	
	[MGWU useCrashlyticsWithApiKey:@"ac9686db8105f5670723f5c12f0681d52bfcd587"];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)tokenId {
    [MGWU registerForPush:tokenId];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [MGWU gotPush:userInfo];
}


- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    [MGWU failedPush:error];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [MGWU gotLocalPush:notification];
}

-(id) alternateView
{
	return nil;
}

@end
