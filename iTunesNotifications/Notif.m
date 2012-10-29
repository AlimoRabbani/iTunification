//
//  Notif.m
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

#import "Notif.h"
#import "iTunes.h"
#import "Spotify.h"

#define NotifieriTunes				@"Now Playing on iTunes"
#define NotifierSpotify				@"Now Playing on Spotify"
#define NotifieriTunesHumanReadableDescription				NSLocalizedString(@"Now Playing on iTunes", "")
#define NotifierSpotifyHumanReadableDescription			NSLocalizedString(@"Now Playing on Spotify", "")


@implementation Notif

@synthesize DNC;
@synthesize silentMode;
@synthesize growlIcon;

- (void) toggleNotifications{
    if(silentMode == true){
        [self turnOnNotifications];
    }
    else{
        [self turnOffNotifications];
    }
}

- (void) turnOnNotifications{
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *path = [mainBundle privateFrameworksPath];
	path = [path stringByAppendingPathComponent:@"Growl.framework"];
	NSBundle *growlFramework = [NSBundle bundleWithPath:path];
	if([growlFramework load])
	{
		Class GAB = NSClassFromString(@"GrowlApplicationBridge");
		if([GAB respondsToSelector:@selector(setGrowlDelegate:)])
			[GAB performSelector:@selector(setGrowlDelegate:) withObject:self];
	}

    DNC = [NSDistributedNotificationCenter defaultCenter];
    [DNC addObserver:self selector:@selector(iTunesNotifications:) name:@"com.apple.iTunes.playerInfo" object:nil];
    [DNC addObserver:self selector:@selector(spotifyNotifications:) name:@"com.spotify.client.PlaybackStateChanged" object:nil];
    silentMode = false;
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}

- (void) turnOffNotifications{
    [DNC removeObserver:self];
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    silentMode = true;
}


- (void) iTunesNotifications:(NSNotification *)note {
    NSString *appName = [[[NSWorkspace sharedWorkspace] activeApplication] valueForKey:@"NSApplicationName"];
    if([appName isEqualToString:@"iTunes"]){
        return;
    }
    NSDictionary *userInfo = [note userInfo];
    NSString *Name = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"Name"]];
    NSString *Artist = [userInfo valueForKey:@"Artist"];
    NSString *Album = [userInfo valueForKey:@"Album"];
    NSString *State = [userInfo valueForKey:@"Player State"];
    if([userInfo objectForKey:@"Stream Title"] != nil){
        Album = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"Name"]];
        Name = [userInfo objectForKey:@"Stream Title"];
    }
    if([State isEqualToString:@"Playing"]){
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        if([GrowlApplicationBridge isGrowlRunning] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"Center"] isEqualToString:@"Growl"]){
            [self sendiTunesGrowlNotification:note];
        }
        else{
            notification.title = Name;
            notification.subtitle = Artist;
            notification.informativeText = Album;
            notification.userInfo = [NSDictionary dictionaryWithObject:@"iTunes" forKey:@"Player"];
            [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }
    }
    else{
        if([GrowlApplicationBridge isGrowlRunning] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"Center"] isEqualToString:@"Growl"]){
        }
        else{
            [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
        }
    }
}


- (void) spotifyNotifications:(NSNotification *)note {
    NSString *appName = [[[NSWorkspace sharedWorkspace] activeApplication] valueForKey:@"NSApplicationName"];
    if([appName isEqualToString:@"Spotify"]){
        return;
    }
    NSDictionary *userInfo = [note userInfo];
    NSString *Artist = [userInfo valueForKey:@"Artist"];
    NSString *Album = [userInfo valueForKey:@"Album"];
    NSString *Name = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"Name"]];
    NSString *State = [userInfo valueForKey:@"Player State"];
    if([userInfo objectForKey:@"Stream Title"] != nil){
        Album = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"Name"]];
        Name = [userInfo objectForKey:@"Stream Title"];
    }
    if([State isEqualToString:@"Playing"]){
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        if([GrowlApplicationBridge isGrowlRunning] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"Center"] isEqualToString:@"Growl"]){
            [self sendSpotifyGrowlNotification:note];
        }
        else{
            notification.title = Name;
            notification.subtitle = Artist;
            notification.informativeText = Album;
            notification.userInfo = [NSDictionary dictionaryWithObject:@"Spotify" forKey:@"Player"];
            [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }
    }
    else{
        if([GrowlApplicationBridge isGrowlRunning] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"Center"] isEqualToString:@"Growl"]){
        }
        else{
            [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
        }
    }
}

- (void)sendiTunesGrowlNotification:(NSNotification *)note{
    NSDictionary *userInfo = [note userInfo];
    NSString *Name = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"Name"]];
    NSString *Artist = [userInfo valueForKey:@"Artist"];
    NSString *Album = [userInfo valueForKey:@"Album"];
    NSString *Year = [userInfo valueForKey:@"Year"];
    NSString *Genre = [userInfo valueForKey:@"Genre"];
    NSUInteger ratingInt = [[userInfo valueForKey:@"Rating"] integerValue];
    NSString *Rating = @"";
    growlIcon = [Notif iTunesArtworkImage];
    if([userInfo objectForKey:@"Stream Title"] != nil){
        Album = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"Name"]];
        Name = [userInfo objectForKey:@"Stream Title"];
    }
    for (int i = 0; i < ratingInt*5/100; i++) {
        Rating = [Rating stringByAppendingString:@"★"];
    }
    if(Name == nil){
        Name = @"Unknown Track";
    }
    if(Artist == nil){
        Artist = @"Unknown Artist";
    }
    if(Album == nil){
        Album = @"Unknown Album";
    }
    if([Rating isEqualToString:@""]){
        Rating = @"No Rating";
    }
    if(Year == nil){
        Year = @"Year N/A";
    }
    if(Genre == nil){
        Genre = @"Genre N/A";
    }

    bool trackEnabled, artistEnabled, albumEnabled, ratingEnabled, yearEnabled, genreEnabled;
    trackEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlTrack"];
    artistEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlArtist"];
    albumEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlAlbum"];
    ratingEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlRating"];
    yearEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlYear"];
    genreEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlGenre"];
    
    
    NSString *notifTitle = [[NSString alloc] init];
    if(trackEnabled)
        notifTitle = [notifTitle stringByAppendingString:[NSString stringWithFormat:@"%@", Name]];
    if(artistEnabled){
        if(trackEnabled){
            notifTitle = [notifTitle stringByAppendingString:[NSString stringWithFormat:@"\n"]];
        }
        notifTitle = [notifTitle stringByAppendingString:[NSString stringWithFormat:@"%@", Artist]];
    }
    if(albumEnabled){
        if(artistEnabled || trackEnabled){
            notifTitle = [notifTitle stringByAppendingString:[NSString stringWithFormat:@"\n"]];
        }
        notifTitle = [notifTitle stringByAppendingString:[NSString stringWithFormat:@"%@", Album]];
    }

    NSString *notifDescription = @"";
    if(ratingEnabled)
        notifDescription = [notifDescription stringByAppendingString:[NSString stringWithFormat:@"%@", Rating]];
    if(yearEnabled){
        if(ratingEnabled){
            notifDescription = [notifDescription stringByAppendingString:[NSString stringWithFormat:@" - "]];
        }
        notifDescription = [notifDescription stringByAppendingString:[NSString stringWithFormat:@"%@", Year]];
    }
    if(genreEnabled){
        if(ratingEnabled || yearEnabled){
            notifDescription = [notifDescription stringByAppendingString:[NSString stringWithFormat:@" - "]];
        }
        notifDescription = [notifDescription stringByAppendingString:[NSString stringWithFormat:@"%@", Genre]];
    }
    [GrowlApplicationBridge notifyWithTitle:notifTitle description:notifDescription notificationName:(NSString *)NotifieriTunes iconData:growlIcon priority:0 isSticky:NO clickContext:@"iTunes" identifier:@"iTunes"];
    growlIcon = nil;
}

- (void)sendSpotifyGrowlNotification:(NSNotification *)note{
    NSDictionary *userInfo = [note userInfo];
    NSString *Name = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"Name"]];
    NSString *Artist = [userInfo valueForKey:@"Artist"];
    NSString *Album = [userInfo valueForKey:@"Album"];
    NSString *Year = [userInfo valueForKey:@"Year"];
    NSString *Genre = [userInfo valueForKey:@"Genre"];
    NSUInteger ratingInt = [[userInfo valueForKey:@"Rating"] integerValue];
    NSString *Rating = @"";
    if([userInfo objectForKey:@"Stream Title"] != nil){
        Album = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"Name"]];
        Name = [userInfo objectForKey:@"Stream Title"];
    }
    for (int i = 0; i < ratingInt*5/100; i++) {
        Rating = [Rating stringByAppendingString:@"★"];
    }
    if(Name == nil){
        Name = @"Unknown Track";
    }
    if(Artist == nil){
        Artist = @"Unknown Artist";
    }
    if(Album == nil){
        Album = @"Unknown Album";
    }
    if([Rating isEqualToString:@""]){
        Rating = @"No Rating";
    }
    if(Year == nil){
        Year = @"Year N/A";
    }
    if(Genre == nil){
        Genre = @"Genre N/A";
    }
    
    bool trackEnabled, artistEnabled, albumEnabled, ratingEnabled, yearEnabled, genreEnabled;
    trackEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlTrack"];
    artistEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlArtist"];
    albumEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlAlbum"];
    ratingEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlRating"];
    yearEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlYear"];
    genreEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlGenre"];
    
    
    NSString *notifTitle = [[NSString alloc] init];
    if(trackEnabled)
        notifTitle = [notifTitle stringByAppendingString:[NSString stringWithFormat:@"%@", Name]];
    if(artistEnabled){
        if(trackEnabled){
            notifTitle = [notifTitle stringByAppendingString:[NSString stringWithFormat:@"\n"]];
        }
        notifTitle = [notifTitle stringByAppendingString:[NSString stringWithFormat:@"%@", Artist]];
    }
    if(albumEnabled){
        if(artistEnabled || trackEnabled){
            notifTitle = [notifTitle stringByAppendingString:[NSString stringWithFormat:@"\n"]];
        }
        notifTitle = [notifTitle stringByAppendingString:[NSString stringWithFormat:@"%@", Album]];
    }
    
    NSString *notifDescription = @"";
    if(ratingEnabled)
        notifDescription = [notifDescription stringByAppendingString:[NSString stringWithFormat:@"%@", Rating]];
    if(yearEnabled){
        if(ratingEnabled){
            notifDescription = [notifDescription stringByAppendingString:[NSString stringWithFormat:@" - "]];
        }
        notifDescription = [notifDescription stringByAppendingString:[NSString stringWithFormat:@"%@", Year]];
    }
    if(genreEnabled){
        if(ratingEnabled || yearEnabled){
            notifDescription = [notifDescription stringByAppendingString:[NSString stringWithFormat:@" - "]];
        }
        notifDescription = [notifDescription stringByAppendingString:[NSString stringWithFormat:@"%@", Genre]];
    }
    
    [GrowlApplicationBridge notifyWithTitle:notifTitle description:notifDescription notificationName:(NSString *)NotifieriTunes iconData:[self spotifyArtworkImage] priority:0 isSticky:NO clickContext:@"Spotify" identifier:@"Spotify"];
}

+ (NSData*) iTunesArtworkImage{
    @try{
        iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        id theTrack = [iTunes currentTrack];
        SBElementArray* theArtworks = [theTrack artworks];
        NSUInteger totalArtworkCount = [theArtworks count];
        NSData* artworkImageData;
        if (totalArtworkCount > 0) {
            iTunesArtwork *thisArtwork = [theArtworks objectAtIndex:0];
            NSBitmapImageRep *bitmap = [[[thisArtwork data] representations] objectAtIndex:0];
            artworkImageData = [bitmap representationUsingType:NSPNGFileType properties:nil];
            return artworkImageData;
        } else {
            return nil;
        }
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (NSData*) spotifyArtworkImage{
    @try {
        SpotifyApplication *Spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
        id theTrack = [Spotify currentTrack];
        NSData* artworkImageData;
        NSImage *thisArtwork = [theTrack artwork];
        NSBitmapImageRep *bitmap = [[thisArtwork representations] objectAtIndex:0];
        artworkImageData = [bitmap representationUsingType:NSPNGFileType properties:nil];
        return artworkImageData;
    }
    @catch (NSException *exception) {
        return nil;
    }
}


-(void)dealloc {
    [DNC removeObserver:self];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

-(void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSString *player = [userInfo valueForKey:@"Player"];
    if([player isEqualToString:@"iTunes"]){
        [[NSWorkspace sharedWorkspace] launchApplicationAtURL:[[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.apple.iTunes"]  options:NSWorkspaceLaunchDefault configuration:nil error:nil];
    }
    else{
        [[NSWorkspace sharedWorkspace] launchApplicationAtURL:[[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.spotify.client"]  options:NSWorkspaceLaunchDefault configuration:nil error:nil];        
    }
}

- (void) growlNotificationWasClicked:(id)clickContext{
    NSString *player = clickContext;
    if([player isEqualToString:@"iTunes"]){
        [[NSWorkspace sharedWorkspace] launchApplicationAtURL:[[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.apple.iTunes"]  options:NSWorkspaceLaunchDefault configuration:nil error:nil];
    }
    else{
        [[NSWorkspace sharedWorkspace] launchApplicationAtURL:[[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.spotify.client"]  options:NSWorkspaceLaunchDefault configuration:nil error:nil];
    }
    
}

- (NSDictionary *) registrationDictionaryForGrowl {
	NSDictionary *notificationsWithDescriptions = [NSDictionary dictionaryWithObjectsAndKeys:NotifieriTunesHumanReadableDescription, NotifieriTunes, NotifierSpotifyHumanReadableDescription, NotifierSpotify, nil];
	
	NSArray *allNotifications = [notificationsWithDescriptions allKeys];
	
	//Don't turn the sync notiifications on by default; they're noisy and not all that interesting.
	NSMutableArray *defaultNotifications = [allNotifications mutableCopy];
	
	NSDictionary *regDict = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"iTunification", GROWL_APP_NAME,
							 allNotifications, GROWL_NOTIFICATIONS_ALL,
							 defaultNotifications,	GROWL_NOTIFICATIONS_DEFAULT,
							 notificationsWithDescriptions,	GROWL_NOTIFICATIONS_HUMAN_READABLE_NAMES,
							 nil];
	
	
	return regDict;
}


@end
