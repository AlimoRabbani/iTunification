//
//  Notif.h
//  iTunes Notifications
//
//  Created by Alimohammad Rabbani on 8/13/12.
//  Copyright (c) 2012 Alimohammad Rabbani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>

@interface Notif : NSObject <NSUserNotificationCenterDelegate, GrowlApplicationBridgeDelegate>

@property NSDistributedNotificationCenter* DNC;
@property BOOL silentMode;

- (void) toggleNotifications;
- (void) turnOnNotifications;
- (void) turnOffNotifications;
- (void) iTunesNotifications:(NSNotification *)note;
- (void) sendiTunesGrowlNotification:(NSNotification *)note;
- (void) spotifyNotifications:(NSNotification *)note;
- (void) sendSpotifyGrowlNotification:(NSNotification *)note;
- (NSData*) iTunesArtworkImage;
- (NSData*) spotifyArtworkImage;

@end
