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
//  PreferencesWindowController.h
//  Portsmouth


#import <Cocoa/Cocoa.h>
#import "PortsmouthConfigData.h"
#import "RoundedCornerOverlayWindow.h"
#import "ShortcutRecorder.h"

@interface PreferencesWindowController : NSWindowController
{
    PortsmouthConfigData *_config;
    PortsmouthConfigData *_defaultConfig;
    
    NSTextField *_hotzoneSize;
    NSTextField *_borderSize;
	SRRecorderControl *_shortcutRecorder;
	SRRecorderControl *_screenSaverRecorder;
	SRRecorderControl *_lockScreenRecorder;
	NSTextField *_version;
}


@property PortsmouthConfigData *config;

@property IBOutlet NSTextField *hotzoneSize;
@property IBOutlet NSTextField *borderSize;
@property IBOutlet SRRecorderControl *shortcutRecorder;
@property IBOutlet SRRecorderControl *screenSaverRecorder;
@property IBOutlet SRRecorderControl *lockScreenRecorder;
@property BOOL shouldStartAtLogin;
@property IBOutlet NSTextField *version;

-(IBAction)showPreferences:(id)sender;
-(id)initWithConfig:(PortsmouthConfigData *)configuration;

-(IBAction)restoreDefaults:(id)sender;

-(IBAction)changeHotZoneSize:(id)sender;

-(IBAction)changeBorderSize:(id)sender;

@end
