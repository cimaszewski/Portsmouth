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
    if (!AXAPIEnabled())
    {
        
        NSAlert *accessAlert = [[NSAlert alloc] init];
        
        [accessAlert setAlertStyle:NSWarningAlertStyle];
        [accessAlert setMessageText:@"Portsmouth requires that the Accessibility API be enabled."];
        [accessAlert setInformativeText:@"Would you like to launch System Preferences so that you can turn on \"Enable access for assistive devices\"?"];
        [accessAlert addButtonWithTitle:@"Open System Preferences"];
        [accessAlert addButtonWithTitle:@"Continue Anyway"];
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
                
            case NSAlertThirdButtonReturn:
                [NSApp terminate:self];
                return;
                break;
                
            case NSAlertSecondButtonReturn: // just continue
            default:
                break;
                
                
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
	
	_config.keyCombo = shortcut;
	
    
    [NSColor setIgnoresAlpha:NO];
    
    _preferencesController = [[PreferencesWindowController alloc]initWithConfig:_config];
    
    _windowSnapController = [[WindowSnapController alloc] initWithConfig:_config];
    
    _moverController = [[WindowMoverController alloc]initWithConfig:_config];
	
	
    
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

