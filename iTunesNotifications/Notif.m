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
@synthesize silentMode, lastNotifPlayer;
@synthesize songDetailsMenu;
@synthesize lastImage;

- (void) toggleNotifications{
    if(silentMode == true){
        //[self turnOnNotifications];
        silentMode = false;
    }
    else{
        //[self turnOffNotifications];
        silentMode = true;
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
    NSDictionary *userInfo = [note userInfo];
    NSString *Name = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"Name"]];
    NSString *Artist = [userInfo valueForKey:@"Artist"];
    NSString *Album = [userInfo valueForKey:@"Album"];
    NSString *Time = [userInfo valueForKey:@"Total Time"];
    NSString *State = [userInfo valueForKey:@"Player State"];
    if([userInfo objectForKey:@"Stream Title"] != nil){
        Album = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"Name"]];
        Name = [userInfo objectForKey:@"Stream Title"];
    }
    self.lastNotifPlayer = @"iTunes";
    if([State isEqualToString:@"Playing"]){
        [self updateStatusBarWithSong:Name Artist:Artist Album:Album Time:Time];
    }
    else{
        [self cleanStatus];
    }
    
    NSString *appName = [[[NSWorkspace sharedWorkspace] activeApplication] valueForKey:@"NSApplicationName"];
    if(([appName isEqualToString:@"iTunes"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"ShowWhenPlayerActive"]) || self.silentMode == true){
        return;
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
            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"KeepHistoryOfNotifications"])
                [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }
    }
    else{
        if([GrowlApplicationBridge isGrowlRunning] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"Center"] isEqualToString:@"Growl"]){
        }
        else{
            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"KeepHistoryOfNotifications"])
                [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
        }
    }
}


- (void) spotifyNotifications:(NSNotification *)note {
    NSDictionary *userInfo = [note userInfo];
    NSString *Artist = [userInfo valueForKey:@"Artist"];
    NSString *Album = [userInfo valueForKey:@"Album"];
    NSString *Name = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"Name"]];
    NSString *Time = [userInfo valueForKey:@"Duration"];
    NSString *State = [userInfo valueForKey:@"Player State"];
    if([userInfo objectForKey:@"Stream Title"] != nil){
        Album = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"Name"]];
        Name = [userInfo objectForKey:@"Stream Title"];
    }
    
    self.lastNotifPlayer = @"Spotify";
    if([State isEqualToString:@"Playing"]){
        [self updateStatusBarWithSong:Name Artist:Artist Album:Album Time:Time];
    }
    else{
        [self cleanStatus];
    }
    
    NSString *appName = [[[NSWorkspace sharedWorkspace] activeApplication] valueForKey:@"NSApplicationName"];
    if(([appName isEqualToString:@"Spotify"] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"ShowWhenPlayerActive"]) || self.silentMode == true){
        return;
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
            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"KeepHistoryOfNotifications"])
                [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }
    }
    else{
        if([GrowlApplicationBridge isGrowlRunning] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"Center"] isEqualToString:@"Growl"]){
        }
        else{
            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"KeepHistoryOfNotifications"])
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
    [GrowlApplicationBridge notifyWithTitle:notifTitle description:notifDescription notificationName:(NSString *)NotifieriTunes iconData:[self iTunesArtworkImageData] priority:0 isSticky:NO clickContext:@"iTunes" identifier:@"iTunes"];
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
    
    [GrowlApplicationBridge notifyWithTitle:notifTitle description:notifDescription notificationName:(NSString *)NotifieriTunes iconData:[self spotifyArtworkImageData] priority:0 isSticky:NO clickContext:@"Spotify" identifier:@"Spotify"];
}

- (void) updateInitialStatus{
    BOOL iTunesRunning, SpotifyRunning;
    iTunesRunning = SpotifyRunning = NO;
    for (NSRunningApplication *currApp in [[NSWorkspace sharedWorkspace] runningApplications]) {
        if([[currApp bundleIdentifier] isEqualToString:@"com.apple.iTunes"])
            iTunesRunning = YES;
        else if([[currApp bundleIdentifier] isEqualToString:@"com.spotify.client"])
            SpotifyRunning = YES;
    }
    
    if(iTunesRunning){
        iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        if ([iTunes playerState] != iTunesEPlSPaused && [iTunes playerState] != iTunesEPlSStopped){
            NSString *Artist = [[iTunes currentTrack] artist];
            NSString *Album = [[iTunes currentTrack] album];
            NSInteger TimeInt = [[iTunes currentTrack] duration];
            TimeInt = TimeInt * 1000;
            NSString *Time = [NSString stringWithFormat:@"%lu", TimeInt];
            NSString *Title = [[iTunes currentTrack] name];
            if([iTunes currentStreamTitle] != nil){
                Album = [NSString stringWithFormat:@"%@", [[iTunes currentTrack] name]];
                Title = [iTunes currentStreamTitle];
            }
            self.lastNotifPlayer = @"iTunes";
            [self updateStatusBarWithSong:Title Artist:Artist Album:Album Time:Time];
            return;
        }
    }
    if(SpotifyRunning){
        SpotifyApplication *spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
        if ([spotify playerState] != SpotifyEPlSPaused && [spotify playerState] != SpotifyEPlSStopped) {
            NSString *Artist = [[spotify currentTrack] artist];
            NSString *Album = [[spotify currentTrack] album];
            NSInteger TimeInt = [[spotify currentTrack] duration];
            NSString *Time = [NSString stringWithFormat:@"%lu", TimeInt];
            NSString *Title = [[spotify currentTrack] name];
            self.lastNotifPlayer = @"Spotify";
            [self updateStatusBarWithSong:Title Artist:Artist Album:Album Time:Time];
            return;
        }
    }
    [self cleanStatus];
}

- (void) cleanStatus{
    NSString *defaultTitle = @"Music not playing...";
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *titleFont = [fontManager fontWithFamily:@"Lucida Grande" traits:0 weight:0 size:14.0f];
    defaultTitle = [self appropriateStringWithString:defaultTitle WithFont:titleFont WithSize:268];
    NSMutableAttributedString *attributed_title = [[NSMutableAttributedString alloc] initWithString:defaultTitle];
    NSDictionary *defaultOptions = [NSDictionary dictionaryWithObjectsAndKeys:titleFont, NSFontAttributeName, nil];
    [attributed_title addAttributes:defaultOptions range:[defaultTitle rangeOfString:defaultTitle]];
    [self.songDetailsMenu setAttributedTitle:attributed_title];
    [self.songDetailsMenu setImage:nil];
    [self.songDetailsMenu setEnabled:NO];
}


- (NSData*) iTunesArtworkImageData{
    @try{
            NSBitmapImageRep *bitmap = [[self.lastImage representations] objectAtIndex:0];
            return [bitmap representationUsingType:NSPNGFileType properties:nil];
        } 
    @catch (NSException *exception) {
        return nil;
    }
}

- (void) iTunesArtworkImage{
    @try{
        iTunesApplication * iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        iTunesTrack *current = [iTunes currentTrack];
        iTunesArtwork *artwork = (iTunesArtwork *)[[[current artworks] get] lastObject];
        if(artwork != nil)
            self.lastImage = [[NSImage alloc] initWithData:[artwork rawData]];
        else
            self.lastImage = [[NSBundle mainBundle] imageForResource:@"icon_128x128.png"];
    }
    @catch (NSException *exception) {
        self.lastImage = [[NSBundle mainBundle] imageForResource:@"icon_128x128.png"];
    }
}


- (NSData*) spotifyArtworkImageData{
    @try {
        NSBitmapImageRep *bitmap = [[self.lastImage representations] objectAtIndex:0];
        return [bitmap representationUsingType:NSPNGFileType properties:nil];
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (void) spotifyArtworkImage{
    @try{
        SpotifyApplication *Spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
        SpotifyTrack *current = [Spotify currentTrack];
        if([current artwork] != nil)
            self.lastImage = [current artwork];
        else
            self.lastImage = [[NSBundle mainBundle] imageForResource:@"icon_128x128.png"];
    }
    @catch (NSException *exception) {
        self.lastImage = [[NSBundle mainBundle] imageForResource:@"icon_128x128.png"];
    }
}

- (void) updateStatusBarWithSong:(NSString *)songTitle Artist:(NSString *)artist Album:(NSString *)album Time:(NSString *)totalTime{
    if(songTitle == nil){
        songTitle = @"Unknown Track";
    }
    if(artist == nil){
        artist = @"Unknown Artist";
    }
    if(album == nil){
        album = @"Unknown Album";
    }
    if(totalTime == nil){
        totalTime = @"Unknown Album";
    }
    NSUInteger timeInt = [totalTime integerValue];
    NSString *prettyTime;
    if([self.lastNotifPlayer isEqualToString:@"iTunes"]){
        prettyTime = [NSString stringWithFormat:@"%lu:%.2lu", timeInt/60000, (timeInt%60000)/1000];
    }
    else if([self.lastNotifPlayer isEqualToString:@"Spotify"]){
        prettyTime = [NSString stringWithFormat:@"%lu:%.2lu", timeInt/60, timeInt%60];        
    }
    

    songTitle = [@"  " stringByAppendingString:songTitle];
    artist = [@"  " stringByAppendingString:artist];
    album = [@"  " stringByAppendingString:album];
    prettyTime = [@"  " stringByAppendingString:prettyTime];
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *songFont = [fontManager fontWithFamily:@"Lucida Grande" traits:NSBoldFontMask weight:4 size:11.0f];
    NSFont *restFont = [fontManager fontWithFamily:@"Lucida Grande" traits:0 weight:0 size:11.0f];

    songTitle = [self appropriateStringWithString:songTitle WithFont:songFont WithSize:200];
    artist = [self appropriateStringWithString:artist WithFont:restFont WithSize:200];
    album = [self appropriateStringWithString:album WithFont:restFont WithSize:200];
    
    NSString *menuTitle = [NSString stringWithFormat:@"%@\n%@\n%@\n%@", songTitle, artist, album, prettyTime];
    NSMutableAttributedString *attributed_title = [[NSMutableAttributedString alloc] initWithString:menuTitle];

    NSDictionary *song_options = [NSDictionary dictionaryWithObjectsAndKeys:songFont, NSFontAttributeName, nil];
    NSDictionary *rest_options = [NSDictionary dictionaryWithObjectsAndKeys:restFont, NSFontAttributeName, nil];
    
    //    NSDictionary *sub_title_options = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor disabledControlTextColor],NSForegroundColorAttributeName,nil];
    
    [attributed_title addAttributes:song_options range:[menuTitle rangeOfString:songTitle]];
    [attributed_title addAttributes:rest_options range:[menuTitle rangeOfString:artist]];
    [attributed_title addAttributes:rest_options range:[menuTitle rangeOfString:album]];
    [attributed_title addAttributes:rest_options range:[menuTitle rangeOfString:prettyTime]];
    // finally set our attributed to the menu item
    [songDetailsMenu setAttributedTitle:attributed_title];
    if([self.lastNotifPlayer isEqualToString:@"iTunes"]){
        [self iTunesArtworkImage];
    }
    else if([self.lastNotifPlayer isEqualToString:@"Spotify"]){
        [self spotifyArtworkImage];
    }
    @try{
        [self.lastImage setSize:NSSizeFromString(@"65x65")];
        [songDetailsMenu setImage:self.lastImage];
    }
    @catch (NSException *exception) {
        self.lastImage = [[NSBundle mainBundle] imageForResource:@"icon_128x128.png"];
        [self.lastImage setSize:NSSizeFromString(@"65x65")];
        [songDetailsMenu setImage:self.lastImage];
    }
    [self.songDetailsMenu setEnabled:YES];
}

- (NSString *)appropriateStringWithString:(NSString *)string WithFont:(NSFont *)font WithSize:(NSUInteger)width{
    NSString *result = string;
    NSDictionary *stringOptions = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    if([result sizeWithAttributes:stringOptions].width > width){
        NSRange range = NSMakeRange([result length] - 3, 3);
        result = [result stringByReplacingCharactersInRange:range withString:@"..."];
        while ([result sizeWithAttributes:stringOptions].width > width) {
            range = NSMakeRange([result length] - 4, 1);
            result = [result stringByReplacingCharactersInRange:range withString:@""];
        }
    }
    else if([result sizeWithAttributes:stringOptions].width < width){
        while ([result sizeWithAttributes:stringOptions].width < width) {
            result = [result stringByAppendingString:@" "];
        }
    }
    return result;
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
