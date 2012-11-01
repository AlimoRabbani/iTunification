//
//  com_onibleAppDelegate.h
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

#import <Cocoa/Cocoa.h>
#import "Notif.h"

@interface com_onibleAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property (strong) Notif *notif;
@property (strong) NSStatusItem *theItem;
@property (strong) IBOutlet NSMenuItem *silentModeMenu;
@property (strong) IBOutlet NSMenuItem *songDetailsMenu;


@property (strong) IBOutlet NSWindow *aboutWindow;
@property (strong) IBOutlet NSWindow *preferencesWindow;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong) IBOutlet NSButtonCell *startAtLoginCheckBox;
@property (strong) IBOutlet NSMatrix *growlNCSelectionGroup;
@property (strong) IBOutlet NSButton *keepHistoryCheckBox;
@property (strong) IBOutlet NSButton *showWhenActiveCheckBox;

@property (strong) IBOutlet NSButton *GrowlTrackBox;
@property (strong) IBOutlet NSButton *GrowlArtistBox;
@property (strong) IBOutlet NSButton *GrowlAlbumBox;
@property (strong) IBOutlet NSButton *GrowlRatingBox;
@property (strong) IBOutlet NSButton *GrowlYearBox;
@property (strong) IBOutlet NSButton *GrowlGenreBox;

@property (strong) IBOutlet NSMenu *theMenu;



- (IBAction)terminateApplication:(id)sender;
- (IBAction)showAboutWindow:(id)sender;
- (IBAction)hideStatusBarIcon:(id)sender;
- (IBAction)hideStatusBarIconTemp:(id)sender;
- (IBAction)toggleNotifications:(id)sender;
- (IBAction)showPreferencesWindow:(id)sender;
- (IBAction)openPlayer:(id)sender;

- (BOOL)isStartAtLogin;
- (void)setStartAtLogin:(NSURL *)bundleURL enabled:(BOOL)enabled;

- (IBAction)findSelectedButton:(id)sender;
- (IBAction)getValue:(id)sender;

- (IBAction)getNotificationPrefs:(id)sender;

- (void) initializations;
- (void) makeStatusBar;

@end
