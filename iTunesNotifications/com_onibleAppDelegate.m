//
//  com_onibleAppDelegate.m
//  iTunesNotifications
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

#import "com_onibleAppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>


@implementation com_onibleAppDelegate

@synthesize startAtLoginCheckBox, keepHistoryCheckBox, showWhenActiveCheckBox;
@synthesize growlNCSelectionGroup;
@synthesize GrowlTrackBox;
@synthesize GrowlArtistBox;
@synthesize GrowlAlbumBox;
@synthesize GrowlRatingBox;
@synthesize GrowlYearBox;
@synthesize GrowlGenreBox;

@synthesize notif;
@synthesize theItem;
@synthesize silentModeMenu, songDetailsMenu;
@synthesize aboutWindow;
@synthesize preferencesWindow;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self initializations];
}


// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.onible.iTunesNotifications" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.onible.iTunesNotifications"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iTunesNotifications" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"iTunesNotifications.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}


- (void) initializations{
    NSString *center = [[NSUserDefaults standardUserDefaults] objectForKey:@"Center"];
    if(center == nil){
        [[NSUserDefaults standardUserDefaults] setObject:@"NC" forKey:@"Center"];
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"ShowWhenPlayerActive"] == nil){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ShowWhenPlayerActive"];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"KeepHistoryOfNotifications"] == nil){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"KeepHistoryOfNotifications"];
    }

    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"GrowlTrack"] == nil){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GrowlTrack"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GrowlArtist"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GrowlAlbum"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GrowlRating"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GrowlYear"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GrowlGenre"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    notif = [[Notif alloc] init];
    notif.songDetailsMenu = songDetailsMenu;
    notif.lastNotifPlayer = @"iTunes";
    [notif turnOnNotifications];
    BOOL hiddenStatusBar = [[NSUserDefaults standardUserDefaults] boolForKey:@"HiddenStatusBar"];
    if(hiddenStatusBar != true){
        [self makeStatusBar];
    }
    [notif updateInitialStatus];
}

- (void)makeStatusBar{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    theItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    NSImage *barIcon = [NSImage imageNamed:@"icon"];
    [barIcon setSize:NSSizeFromString(@"17x17")];
    [theItem setImage:barIcon];
    [theItem setHighlightMode:YES];
    [theItem setMenu:self.theMenu];
}

- (IBAction)terminateApplication:(id)sender {
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    [NSApp terminate:self];
}

- (IBAction)showAboutWindow:(id)sender {
    [self.aboutWindow makeKeyAndOrderFront:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (IBAction)hideStatusBarIcon:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"HiddenStatusBar"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSStatusBar systemStatusBar] removeStatusItem:theItem];
}

- (IBAction)hideStatusBarIconTemp:(id)sender {
    [[NSStatusBar systemStatusBar] removeStatusItem:theItem];
}

- (IBAction)toggleNotifications:(id)sender {
    [notif toggleNotifications];
    if(notif.silentMode == true){
        [self.silentModeMenu setState:NSOnState];
    }
    else{
        [self.silentModeMenu setState:NSOffState];
    }
}

- (IBAction)showPreferencesWindow:(id)sender {
    NSString *center = [[NSUserDefaults standardUserDefaults] objectForKey:@"Center"];
    if([center isEqualToString:@"NC"])
        [growlNCSelectionGroup setState:NSOnState atRow:0 column:0];
    else
        [growlNCSelectionGroup setState:NSOnState atRow:1 column:0];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowWhenPlayerActive"])
        [self.showWhenActiveCheckBox setState:NSOnState];
    else
        [self.showWhenActiveCheckBox setState:NSOffState];

    if([[NSUserDefaults standardUserDefaults] boolForKey:@"KeepHistoryOfNotifications"])
        [self.keepHistoryCheckBox setState:NSOnState];
    else
        [self.keepHistoryCheckBox setState:NSOffState];

    
    bool GrowlPref = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlTrack"];
    if(GrowlPref == YES)
        [GrowlTrackBox setState:NSOnState];
    else
        [GrowlTrackBox setState:NSOffState];
    
    GrowlPref = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlArtist"];
    if(GrowlPref == YES)
        [GrowlArtistBox setState:NSOnState];
    else
        [GrowlArtistBox setState:NSOffState];
    
    GrowlPref = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlAlbum"];
    if(GrowlPref == YES)
        [GrowlAlbumBox setState:NSOnState];
    else
        [GrowlAlbumBox setState:NSOffState];
    
    GrowlPref = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlRating"];
    if(GrowlPref == YES)
        [GrowlRatingBox setState:NSOnState];
    else
        [GrowlRatingBox setState:NSOffState];
    
    GrowlPref = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlYear"];
    if(GrowlPref == YES)
        [GrowlYearBox setState:NSOnState];
    else
        [GrowlYearBox setState:NSOffState];
    
    GrowlPref = [[NSUserDefaults standardUserDefaults] boolForKey:@"GrowlGenre"];
    if(GrowlPref == YES)
        [GrowlGenreBox setState:NSOnState];
    else
        [GrowlGenreBox setState:NSOffState];
    
    if([self isStartAtLogin]){
        [self.startAtLoginCheckBox setState:NSOnState];
    }
    else{
        [self.startAtLoginCheckBox setState:NSOffState];
    }
    
    [self.preferencesWindow makeKeyAndOrderFront:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (IBAction)openPlayer:(id)sender {
    if([notif.lastNotifPlayer isEqualToString:@"iTunes"]){
        [[NSWorkspace sharedWorkspace] launchApplicationAtURL:[[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.apple.iTunes"]  options:NSWorkspaceLaunchDefault configuration:nil error:nil];
    }
    else if([notif.lastNotifPlayer isEqualToString:@"Spotify"]){
        [[NSWorkspace sharedWorkspace] launchApplicationAtURL:[[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.spotify.client"]  options:NSWorkspaceLaunchDefault configuration:nil error:nil];
    }

}

- (BOOL)isStartAtLogin {
    NSString *bundleID = @"com.onible.iTunificationStartup";
    NSArray * jobDicts = nil;
    jobDicts = (NSArray *)CFBridgingRelease(SMCopyAllJobDictionaries( kSMDomainUserLaunchd ));    
    if ( (jobDicts != nil) && [jobDicts count] > 0 ) {
        
        BOOL bOnDemand = NO;
        
        for ( NSDictionary * job in jobDicts ) {
            
            if ( [bundleID isEqualToString:[job objectForKey:@"Label"]] ) {
                bOnDemand = [[job objectForKey:@"OnDemand"] boolValue];
                break;
            }
        }
        CFRelease((CFDictionaryRef)CFBridgingRetain(jobDicts)); jobDicts = nil;
        return bOnDemand;
    }
    return NO;
}

- (IBAction)getValue:(id)sender{
    NSButton *button = sender;
    if([[sender identifier] isEqualToString:@"Startup"]){
        if ([button state] == NSOnState)
            [self setStartAtLogin:[[NSBundle mainBundle] bundleURL] enabled:YES];
        else
            [self setStartAtLogin:[[NSBundle mainBundle] bundleURL] enabled:NO];
    }
    else if([[sender identifier] isEqualToString:@"KeepHistory"]){
        if([button state] == NSOnState)
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"KeepHistoryOfNotifications"];
        else
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"KeepHistoryOfNotifications"];
    }
    else if([[sender identifier] isEqualToString:@"ShowWhenActive"]){
        if([button state] == NSOnState)
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShowWhenPlayerActive"];
        else
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ShowWhenPlayerActive"];
    }
}


- (void)setStartAtLogin:(NSURL *)bundleURL enabled:(BOOL)enabled {
	// Creating helper app complete URL
	NSURL *url = [bundleURL URLByAppendingPathComponent:
                  @"Contents/Library/LoginItems/iTunificationStartup.app"];
    
	// Registering helper app
	if (LSRegisterURL((CFURLRef)CFBridgingRetain(url), true) != noErr) {
		NSLog(@"LSRegisterURL failed!");
	}
    
	// Setting login
	if (!SMLoginItemSetEnabled((CFStringRef)@"com.onible.iTunificationStartup", enabled)) {
		NSLog(@"SMLoginItemSetEnabled failed!");
	}
}

- (IBAction)findSelectedButton:(id)sender {
    NSButtonCell *selCell = [sender selectedCell];
    if(selCell.tag == 1){
        [[NSUserDefaults standardUserDefaults] setObject:@"NC" forKey:@"Center"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setObject:@"Growl" forKey:@"Center"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)getNotificationPrefs:(id)sender{
    NSButton *changedCell = sender;
    switch (changedCell.tag) {
        case 0:
            if(changedCell.state == NSOnState){
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GrowlTrack"];
                [[NSUserDefaults standardUserDefaults] synchronize];                
            }
            else{
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GrowlTrack"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            break;
        case 1:
            if(changedCell.state == NSOnState){
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GrowlArtist"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else{
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GrowlArtist"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            break;
        case 2:
            if(changedCell.state == NSOnState){
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GrowlAlbum"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else{
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GrowlAlbum"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            break;
        case 3:
            if(changedCell.state == NSOnState){
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GrowlRating"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else{
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GrowlRating"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            break;
        case 4:
            if(changedCell.state == NSOnState){
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GrowlYear"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else{
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GrowlYear"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            break;
        case 5:
            if(changedCell.state == NSOnState){
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GrowlGenre"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else{
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GrowlGenre"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            break;            
        default:
            break;
    }
}

@end
