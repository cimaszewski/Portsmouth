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
//  PreferencesWindowController.m
//  Portsmouth


#import "PreferencesWindowController.h"
#import "Portsmouth.h"
#import "RoundedCornerOverlayWindow.h"
#import "WindowHotzoneData.h"
#import "LoginItems.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController

@synthesize config=_config;
@synthesize hotzoneSize=_hotzoneSize;
@synthesize borderSize=_borderSize;
@synthesize shortcutRecorder=_shortcutRecorder;
@synthesize lockScreenRecorder=_lockScreenRecorder;
@synthesize screenSaverRecorder=_screenSaverRecorder;
@synthesize version=_version;

NSString *const PORTSMOUTH_VERSION = @"1.0b";

-(void) windowDidLoad
{
	[_hotzoneSize setStringValue:[NSString stringWithFormat:@"%d%%", (int)(_config.hotzoneWidthPercentage*100)]];
	[_borderSize setStringValue:[NSString stringWithFormat:@"%d", (int)(_config.borderWidth)]];
	
	[_shortcutRecorder setAllowsKeyOnly:NO escapeKeysRecord:NO];
	[_shortcutRecorder setKeyCombo:_config.keyCombo];
	
	[_lockScreenRecorder setAllowsKeyOnly:NO escapeKeysRecord:NO];
	[_lockScreenRecorder setKeyCombo:_config.lockScreenKeyCombo];
	
	[_screenSaverRecorder setAllowsKeyOnly:NO escapeKeysRecord:NO];
	[_screenSaverRecorder setKeyCombo:_config.screenSaverKeyCombo];
	
	[_version setStringValue:[NSString stringWithFormat:@"Version: %@", PORTSMOUTH_VERSION]];

}

-(void)awakeFromNib {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(windowMainStatusChanged:) name:NSWindowWillCloseNotification object:[self window]];
}

-(IBAction)showPreferences:(id)sender
{
	if (![[self window] isVisible])
    {
        [[self window] setLevel:kCGPopUpMenuWindowLevel];
        [[self window] center];
		
        [self showWindow:sender];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PAUSE_EVENTS object:nil];
        
        [[NSRunningApplication currentApplication] activateWithOptions: NSApplicationActivateIgnoringOtherApps];
    }
	
}

-(void)loadConfig
{
	
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	
	[self restoreDefaults:nil];
	
	if([settings objectForKey:@"borderStyle"] != nil) {
		_config.borderStyle = [settings integerForKey:@"borderStyle"];
	}
	
	if([settings objectForKey:@"borderWidth"] != nil) {
		_config.borderWidth = [settings floatForKey:@"borderWidth"];
	}
	
	if([settings objectForKey:@"cornerRadius"] != nil) {
		_config.cornerRadius = [settings floatForKey:@"cornerRadius"];
	}
	
	if([settings objectForKey:@"defaultFullScreenToLionFullScreen"] != nil) {
		_config.defaultFullScreenToLionFullScreen = [settings boolForKey:@"defaultFullScreenToLionFullScreen"];
	}
	
	if([settings objectForKey:@"defaultTopToFullScreen"] != nil) {
		_config.defaultTopToFullScreen = [settings boolForKey:@"defaultTopToFullScreen"];
	}
	
	if([settings objectForKey:@"hotzoneWidthPercentage"] != nil) {
		_config.hotzoneWidthPercentage = [settings floatForKey:@"hotzoneWidthPercentage"];
	}
	
	if([settings objectForKey:@"isX11SupportEnabled"] != nil) {
		_config.isX11SupportEnabled = [settings boolForKey:@"isX11SupportEnabled"];
	}
	
	if([settings objectForKey:@"overlayBackgroundColor.red"] != nil
	   && [settings objectForKey:@"overlayBackgroundColor.green"] != nil
	   && [settings objectForKey:@"overlayBackgroundColor.blue"] != nil
	   && [settings objectForKey:@"overlayBackgroundColor.alpha"] != nil) {
		
		_config.overlayBackgroundColor = [NSColor
										  colorWithCalibratedRed:[settings floatForKey:@"overlayBackgroundColor.red"]
										  green:[settings floatForKey:@"overlayBackgroundColor.green"]
										  blue:[settings floatForKey:@"overlayBackgroundColor.blue"]
										  alpha:[settings floatForKey:@"overlayBackgroundColor.alpha"]];
	}
	
	if([settings objectForKey:@"overlayBorderColor.red"] != nil
	   && [settings objectForKey:@"overlayBorderColor.green"] != nil
	   && [settings objectForKey:@"overlayBorderColor.blue"] != nil
	   && [settings objectForKey:@"overlayBorderColor.alpha"] != nil) {
		
		_config.overlayBorderColor = [NSColor
										  colorWithCalibratedRed:[settings floatForKey:@"overlayBorderColor.red"]
										  green:[settings floatForKey:@"overlayBorderColor.green"]
										  blue:[settings floatForKey:@"overlayBorderColor.blue"]
										  alpha:[settings floatForKey:@"overlayBorderColor.alpha"]];
	}
	
	if([settings objectForKey:@"displayTargetOverlay"] != nil) {
		_config.displayTargetOverlay = [settings boolForKey:@"displayTargetOverlay"];
	}
	
	if([settings objectForKey:@"keyCombo.code"] != nil && [settings objectForKey:@"keyCombo.flags"] != nil) {		
		KeyCombo shortcut = SRMakeKeyCombo(ShortcutRecorderEmptyCode, ShortcutRecorderEmptyFlags);
		shortcut.code = [settings integerForKey:@"keyCombo.code"];
		shortcut.flags = [settings integerForKey:@"keyCombo.flags"];
		_config.keyCombo = shortcut;
	} else {
		_config.keyCombo = _defaultConfig.keyCombo;
	}
	
	if([settings objectForKey:@"screenSaverKeyCombo.code"] != nil && [settings objectForKey:@"screenSaverKeyCombo.flags"] != nil) {
		KeyCombo shortcut = SRMakeKeyCombo(ShortcutRecorderEmptyCode, ShortcutRecorderEmptyFlags);
		shortcut.code = [settings integerForKey:@"screenSaverKeyCombo.code"];
		shortcut.flags = [settings integerForKey:@"screenSaverKeyCombo.flags"];
		_config.screenSaverKeyCombo = shortcut;
	} else {
		_config.screenSaverKeyCombo = _defaultConfig.screenSaverKeyCombo;
	}
	
	if([settings objectForKey:@"lockScreenKeyCombo.code"] != nil && [settings objectForKey:@"lockScreenKeyCombo.flags"] != nil) {
		KeyCombo shortcut = SRMakeKeyCombo(ShortcutRecorderEmptyCode, ShortcutRecorderEmptyFlags);
		shortcut.code = [settings integerForKey:@"lockScreenKeyCombo.code"];
		shortcut.flags = [settings integerForKey:@"lockScreenKeyCombo.flags"];
		_config.lockScreenKeyCombo = shortcut;
	} else {
		_config.lockScreenKeyCombo = _defaultConfig.lockScreenKeyCombo;
	}
	
	[_hotzoneSize setStringValue:[NSString stringWithFormat:@"%d%%", (int)(_config.hotzoneWidthPercentage*100)]];
    [_borderSize setStringValue:[NSString stringWithFormat:@"%d", (int)(_config.borderWidth)]];
	[_shortcutRecorder setKeyCombo:_config.keyCombo];
	[_lockScreenRecorder setKeyCombo:_config.lockScreenKeyCombo];
	[_screenSaverRecorder setKeyCombo:_config.screenSaverKeyCombo];
}

-(void)saveConfig
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	
	[settings setInteger:_config.borderStyle forKey:@"borderStyle"];
	[settings setFloat:_config.borderWidth forKey:@"borderWidth"];
	[settings setFloat:_config.cornerRadius forKey:@"cornerRadius"];
	[settings setBool:_config.defaultFullScreenToLionFullScreen forKey:@"defaultFullScreenToLionFullScreen"];
	[settings setBool:_config.defaultTopToFullScreen forKey:@"defaultTopToFullScreen"];
	[settings setFloat:_config.hotzoneWidthPercentage forKey:@"hotzoneWidthPercentage"];
	[settings setBool:_config.isX11SupportEnabled forKey:@"isX11SupportEnabled"];
	
	[settings setFloat:_config.overlayBackgroundColor.redComponent forKey:@"overlayBackgroundColor.red"];
	[settings setFloat:_config.overlayBackgroundColor.greenComponent forKey:@"overlayBackgroundColor.green"];
	[settings setFloat:_config.overlayBackgroundColor.blueComponent forKey:@"overlayBackgroundColor.blue"];
	[settings setFloat:_config.overlayBackgroundColor.alphaComponent forKey:@"overlayBackgroundColor.alpha"];
	
	[settings setFloat:_config.overlayBorderColor.redComponent forKey:@"overlayBorderColor.red"];
	[settings setFloat:_config.overlayBorderColor.greenComponent forKey:@"overlayBorderColor.green"];
	[settings setFloat:_config.overlayBorderColor.blueComponent forKey:@"overlayBorderColor.blue"];
	[settings setFloat:_config.overlayBorderColor.alphaComponent forKey:@"overlayBorderColor.alpha"];
	
	[settings setBool:_config.displayTargetOverlay forKey:@"displayTargetOverlay"];
	[settings setInteger:_config.keyCombo.code forKey:@"keyCombo.code"];
	[settings setInteger:_config.keyCombo.flags forKey:@"keyCombo.flags"];
	
	[settings setInteger:_config.lockScreenKeyCombo.code forKey:@"lockScreenKeyCombo.code"];
	[settings setInteger:_config.lockScreenKeyCombo.flags forKey:@"lockScreenKeyCombo.flags"];
	
	[settings setInteger:_config.screenSaverKeyCombo.code forKey:@"screenSaverKeyCombo.code"];
	[settings setInteger:_config.screenSaverKeyCombo.flags forKey:@"screenSaverKeyCombo.flags"];
	
	
	[settings synchronize];

}

-(IBAction)restoreDefaults:(id)sender
{
    [_config setBorderStyle:_defaultConfig.borderStyle];
    [_config setBorderWidth:_defaultConfig.borderWidth];
    [_config setCornerRadius:_defaultConfig.cornerRadius];
    [_config setDefaultFullScreenToLionFullScreen:_defaultConfig.defaultFullScreenToLionFullScreen];
    [_config setDefaultTopToFullScreen:_defaultConfig.defaultTopToFullScreen];
    [_config setHotzoneWidthPercentage:_defaultConfig.hotzoneWidthPercentage];
    [_config setIsX11SupportEnabled:_defaultConfig.isX11SupportEnabled];
    [_config setOverlayBackgroundColor:[_defaultConfig.overlayBackgroundColor copy]];
    [_config setOverlayBorderColor:[_defaultConfig.overlayBorderColor copy]];
    [_config setDisplayTargetOverlay:_defaultConfig.displayTargetOverlay];
	[_config setKeyCombo:_defaultConfig.keyCombo];
	[_config setLockScreenKeyCombo:_defaultConfig.lockScreenKeyCombo];
	[_config setScreenSaverKeyCombo:_defaultConfig.screenSaverKeyCombo];
	[self setShouldStartAtLogin:NO];
    
    [_hotzoneSize setStringValue:[NSString stringWithFormat:@"%d%%", (int)(_config.hotzoneWidthPercentage*100)]];
    [_borderSize setStringValue:[NSString stringWithFormat:@"%d", (int)(_config.borderWidth)]];
	[_shortcutRecorder setKeyCombo:_config.keyCombo];
	
	[_lockScreenRecorder setKeyCombo:_config.lockScreenKeyCombo];
	[_screenSaverRecorder setKeyCombo:_config.screenSaverKeyCombo];
}

- (BOOL)shouldStartAtLogin {
	NSString *path = [[NSBundle mainBundle] bundlePath];
	return [[LoginItems sharedSessionLoginItems] isInLoginItemsApplicationWithPath:path];
}

- (void)setShouldStartAtLogin:(BOOL)flag {
	NSString *path = [[NSBundle mainBundle] bundlePath];
	[[LoginItems sharedSessionLoginItems] toggleApplicationInLoginItemsWithPath:path enabled:flag];
}

-(IBAction)changeHotZoneSize:(id)sender
{
    log4Debug(@"Changing Hotzone Size");
    [_config setHotzoneWidthPercentage:[sender floatValue]];
    
    [_hotzoneSize setStringValue:[NSString stringWithFormat:@"%d%%", (int)(_config.hotzoneWidthPercentage*100)]];
    
}

-(IBAction)changeBorderSize:(id)sender
{
    log4Debug(@"Changing Hotzone Size");
    [_config setBorderWidth:[sender floatValue]];
    
    [_borderSize setStringValue:[NSString stringWithFormat:@"%d", (int)(_config.borderWidth)]];
    
}

-(id)initWithConfig:(PortsmouthConfigData *)configuration
{
    if (![super initWithWindowNibName:@"PreferencesWindow"]) {
		return nil;
    }
	
	_config = configuration;
    _defaultConfig = [configuration copy];
	
	[self loadConfig];
    
    return self;
}

-(BOOL)acceptsFirstResponder{
	return YES;
}

- (void)windowMainStatusChanged:(NSNotification *)notification {
	NSString *name = [notification name];
    
	if ([name isEqualTo:NSWindowWillCloseNotification]) {
		[self saveConfig];
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UNPAUSE_EVENTS object:nil];
        [NSApp hide:nil];
	}
}

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason
{
	// no need for logic, we only have a single shortcut in this application
	return NO;
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{
	// no work to do, the value is bound in IB
	if (aRecorder == _shortcutRecorder)
	{
		_config.keyCombo = newKeyCombo;
	}
	else if (aRecorder == _lockScreenRecorder)
	{
		_config.lockScreenKeyCombo = newKeyCombo;
	}
	else if (aRecorder == _screenSaverRecorder)
	{
		_config.screenSaverKeyCombo = newKeyCombo;
	}
}

@end
