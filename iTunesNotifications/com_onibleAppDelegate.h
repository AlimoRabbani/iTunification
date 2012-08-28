//
//  com_onibleAppDelegate.h
//  iTunesNotifications
//
//  Created by Alimohammad Rabbani on 8/13/12.
//  Copyright (c) 2012 Alimohammad Rabbani. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Notif.h"

@interface com_onibleAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property (strong) Notif *notif;
@property (strong) NSStatusItem *theItem;
@property (strong) NSMenuItem *showPreferencesMenu;
@property (strong) NSMenuItem *silentModeMenu;
@property (strong) NSMenuItem *hideMenu;
@property (strong) NSMenuItem *hideTempMenu;
@property (strong) NSMenuItem *aboutMenu;
@property (strong) NSMenuItem *quitMenu;


@property (strong) IBOutlet NSWindow *aboutWindow;
@property (strong) IBOutlet NSWindow *preferencesWindow;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong) IBOutlet NSButtonCell *startAtLoginCheckBox;
@property (strong) IBOutlet NSMatrix *growlNCSelectionGroup;

@property (strong) IBOutlet NSButton *GrowlTrackBox;
@property (strong) IBOutlet NSButton *GrowlArtistBox;
@property (strong) IBOutlet NSButton *GrowlAlbumBox;
@property (strong) IBOutlet NSButton *GrowlRatingBox;
@property (strong) IBOutlet NSButton *GrowlYearBox;
@property (strong) IBOutlet NSButton *GrowlGenreBox;



- (void)toggleNotifications;
- (void)terminateApplication;
- (void)hideStatusBarIcon;

- (BOOL)isStartAtLogin;
- (void)setStartAtLogin:(NSURL *)bundleURL enabled:(BOOL)enabled;

- (void)showPreferencesWindow;
- (void)showAboutWindow;

- (IBAction)findSelectedButton:(id)sender;
- (IBAction)getValue:(id)sender;

- (IBAction)getNotificationPrefs:(id)sender;

- (void) initializations;
- (void)makeStatusBar;

@end
