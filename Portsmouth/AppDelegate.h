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
//  AppDelegate.h
//  Portsmouth


#import <Cocoa/Cocoa.h>
#import "WindowSnapController.h"
#import "PreferencesWindowController.h"
#import "WindowMoverController.h"
#import "HotKeyController.h"
#import "System Preferences.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
@private
    
        
    
    WindowSnapController *_windowSnapController;
    PortsmouthConfigData *_config;
    PreferencesWindowController *_preferencesController;
    WindowMoverController *_moverController;
	HotKeyController *_hotKeyController;
    
    NSMenu *_statusMenu;
	NSStatusItem *_statusItem;
	NSImage *_statusMenuItemIcon;
    NSImage *_statusMenuItemHighlightIcon;
    
        
}


@property IBOutlet NSMenu *statusMenu;
@property IBOutlet WindowMoverController *moverController;


@end

