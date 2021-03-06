//  Copyright 2013 Chris Cimaszewski
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  AppDelegate.m
//  Portsmouth


#import <Cocoa/Cocoa.h>
#import <AppKit/NSAccessibility.h>
#import <Carbon/Carbon.h>
#import "AppDelegate.h"
#import "BorderStyle.h"

@implementation AppDelegate

//@synthesize window = _window;
@synthesize statusMenu = _statusMenu;
@synthesize moverController = _moverController;


- (void)awakeFromNib {
    _moverController.config = _config;
}

- (void)handleShowPreferencesRequest:(NSNotification *) notification {
	[self showPreferences:self];
}

- (IBAction)showPreferences:(id)sender {
    [_preferencesController showPreferences:sender];
    //[NSApp activateIgnoringOtherApps:YES];
}


- (IBAction)showMoverModal:(id)sender {

    if (!_moverController) {
        _moverController = [[WindowMoverController alloc]init];
    }
    [_moverController setConfig:_config];
    [_moverController openModal];
}



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // hide the main window of the application
    // I'm not quite sure if this is the proper manner to accomplish this task
    //[self.window setFrame:NSZeroRect display:NO animate:NO];
    
    // Insert code here to initialize your application

	
	if (AXIsProcessTrustedWithOptions == NULL)
	{
		if (!AXAPIEnabled())
		{
			
			NSAlert *accessAlert = [[NSAlert alloc] init];
			
			[accessAlert setAlertStyle:NSWarningAlertStyle];
			[accessAlert setMessageText:@"Portsmouth requires that the Accessibility API be enabled."];
			[accessAlert setInformativeText:@"Would you like to launch System Preferences so that you can turn on \"Enable access for assistive devices\"?"];
			[accessAlert addButtonWithTitle:@"Open System Preferences"];
			[accessAlert addButtonWithTitle:@"Quit Portsmouth"];
			
			NSInteger result = [accessAlert runModal];
			
			switch (result)
			{
				case NSAlertFirstButtonReturn:
				{
					NSArray *paths = NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSSystemDomainMask, YES);
					if ([paths count] == 1) {
						NSURL *prefPaneURL = [NSURL fileURLWithPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"UniversalAccessPref.prefPane"]];
						[[NSWorkspace sharedWorkspace] openURL:prefPaneURL];
					}
				}
					break;
					
				case NSAlertSecondButtonReturn:
					[NSApp terminate:self];
					return;
					break;
					
			}
			
		}
		
    }
	else
	{
		if (!AXAPIEnabled())
		{
			
			NSAlert *accessAlert = [[NSAlert alloc] init];
			
			[accessAlert setAlertStyle:NSWarningAlertStyle];
			[accessAlert setMessageText:@"Portsmouth requires that the Accessibility API be enabled."];
			[accessAlert setInformativeText:@"Would you like to launch System Preferences so that you can allow Portsmouth to control your computer via Accessibility controls?"];
			[accessAlert addButtonWithTitle:@"Open System Preferences"];
			[accessAlert addButtonWithTitle:@"Quit Portsmouth"];
			
			NSInteger result = [accessAlert runModal];
			
			switch (result)
			{
				case NSAlertFirstButtonReturn:
				{
					//Get a reference we can use to send scripting messages to System Preferences.
					//This will not launch the application or establish a connection to it until we start sending it commands.
					SystemPreferencesApplication *prefsApp = [SBApplication applicationWithBundleIdentifier: @"com.apple.systempreferences"];
					
					//Tell the scripting bridge wrapper not to block this thread while waiting for replies from the other process.
					//(The commands we'll be sending it don't have return values that we care about.)
					prefsApp.sendMode = kAENoReply;
					
					//Get a reference to the accessibility anchor within the Security & Privacy pane.
					//If the pane or the anchor don't exist (e.g. they get renamed in a future OS X version),
					//we'll still get objects for them but any commands sent to those objects will silently fail.
					SystemPreferencesPane *securityPane = [prefsApp.panes objectWithID: @"com.apple.preference.security"];
					SystemPreferencesAnchor *accessibilityAnchor = [securityPane.anchors objectWithName: @"Privacy_Accessibility"];
					
					//Open the System Preferences application and bring its window to the foreground.
					[prefsApp activate];
					
					//Show the accessibility anchor, if it exists.
					[accessibilityAnchor reveal];
				}
					break;
					
				case NSAlertSecondButtonReturn:
					[NSApp terminate:self];
					return;
					break;
					
					
			}
			
		}
		
	}
    
    
    NSColor* backgroundColor = [NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:.4];
    NSColor* borderColor = [NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    
    _config = [[PortsmouthConfigData alloc] init];
     _config.hotzoneWidthPercentage = .02;
    _config.borderStyle = solid;
    _config.borderWidth = 1.0;
    _config.cornerRadius = 4;
    _config.overlayBackgroundColor = backgroundColor;
    _config.overlayBorderColor = borderColor;
    _config.defaultTopToFullScreen = YES;
    _config.defaultFullScreenToLionFullScreen = NO;
    _config.isX11SupportEnabled = YES;
    _config.displayTargetOverlay = YES;
	
	KeyCombo shortcut = SRMakeKeyCombo(ShortcutRecorderEmptyCode, ShortcutRecorderEmptyFlags);
	shortcut.code = 49;
	shortcut.flags = NSCommandKeyMask+NSShiftKeyMask;

	KeyCombo shortcutLock = SRMakeKeyCombo(ShortcutRecorderEmptyCode, ShortcutRecorderEmptyFlags);
	shortcutLock.code = 37;
	shortcutLock.flags = NSAlternateKeyMask+NSShiftKeyMask;
	
	KeyCombo saverLock = SRMakeKeyCombo(ShortcutRecorderEmptyCode, ShortcutRecorderEmptyFlags);
	saverLock.code = 37;
	saverLock.flags = NSCommandKeyMask+NSShiftKeyMask;
	
	_config.keyCombo = shortcut;
	_config.lockScreenKeyCombo = shortcutLock;
	_config.screenSaverKeyCombo = saverLock;
	
    
    [NSColor setIgnoresAlpha:NO];
    
    _preferencesController = [[PreferencesWindowController alloc]initWithConfig:_config];
    
    _windowSnapController = [[WindowSnapController alloc] initWithConfig:_config];
    
    _moverController = [[WindowMoverController alloc]initWithConfig:_config];
	
	_hotKeyController = [[HotKeyController alloc] initWithConfig:_config andWindowMoverController:_moverController];
    
    //NSString *iconPath = [[NSBundle mainBundle] pathForResource:@"menuItem" ofType:@"tiff"];
	_statusMenuItemIcon = [NSImage imageNamed:@"menuItem.tiff"];
    _statusMenuItemHighlightIcon = [NSImage imageNamed:@"menuItemHighlight.tiff"];
    
    
    BOOL showIconInMenuBar = YES;
	NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
	
	if(showIconInMenuBar) {
        if(!_statusItem) {
            _statusItem = [statusBar statusItemWithLength:30];
            [_statusItem setMenu:_statusMenu];
            
            if (_statusMenuItemIcon) {
                [_statusItem setImage:_statusMenuItemIcon];
                if (_statusMenuItemHighlightIcon) {
                    [_statusItem setAlternateImage:_statusMenuItemHighlightIcon];
                }
            } else {
                [_statusItem setTitle:@"Portsmouth"];
            }
            [_statusItem setHighlightMode:YES];
            [_statusItem setAction:@selector(statusItemClicked)];
            [_statusItem setTarget:self];
            //[_statusItem setTarget:_statusMenu];
            //[NSApp setMainMenu:_statusMenu];
            
            [_statusItem setEnabled:YES];
        }
	} else {
        [statusBar removeStatusItem:_statusItem];
        _statusItem = nil;
    }

}

- (void)statusItemClicked {
    [_statusItem popUpStatusItemMenu:_statusMenu];

    [NSApp activateIgnoringOtherApps:YES];
}

-(void)applicationDidResignActive:(NSNotification *)notification
{
    [_moverController closeModalWithSelection:NO];
}

@end

