//
//  Notif.h
//  iTunes Notifications
//
//  Created by Alimohammad Rabbani on 8/13/12.
//  Copyright (c) 2012 Alimohammad Rabbani. All rights reserved.
//
//  This file is part of iTunification.
//
//  iTunification is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  iTunification is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with iTunification.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>

@interface Notif : NSObject <NSUserNotificationCenterDelegate, GrowlApplicationBridgeDelegate>

@property NSDistributedNotificationCenter* DNC;
@property BOOL silentMode;
@property (strong) NSMenuItem *songDetailsMenu;

@property (strong) NSImage *lastImage;

@property (strong) NSString *lastNotifPlayer;

- (void) toggleNotifications;
- (void) turnOnNotifications;
- (void) turnOffNotifications;
- (void) iTunesNotifications:(NSNotification *)note;
- (void) sendiTunesGrowlNotification:(NSNotification *)note;
- (void) spotifyNotifications:(NSNotification *)note;
- (void) sendSpotifyGrowlNotification:(NSNotification *)note;
- (void) updateStatusBarWithSong:(NSString *)songTitle Artist:(NSString *)artist Album:(NSString *)album Time:(NSString *)totalTime;
- (void) iTunesArtworkImage;
- (void) spotifyArtworkImage;
- (NSData*) iTunesArtworkImageData;
- (NSData*) spotifyArtworkImageData;
- (NSString *)appropriateStringWithString:(NSString *)string WithFont:(NSFont *)font WithSize:(NSUInteger)width;

- (void) updateInitialStatus;
- (void) cleanStatus;

@end
