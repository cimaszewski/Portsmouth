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
//  ScreenSaverExecutionController.h
//  Portsmouth


#import <Foundation/Foundation.h>
#import "PausableController.h"
#import "PortsmouthConfigData.h"
#import <Carbon/Carbon.h>
#import "WindowMoverController.h"

@interface HotKeyController : PausableController
{
	EventHotKeyRef _showModalHotKeyRef;
	EventHotKeyRef _screenSaverHotKeyRef;
	EventHotKeyRef _lockScreenHotKeyRef;
    
    EventHotKeyID _hotKeyID;
	EventHotKeyID _screenSaverKeyID;
	EventHotKeyID _lockScreenKeyID;
    
    CFTypeRef _selfRef;
	WindowMoverController *_windowMoverController;
	PortsmouthConfigData *_config;
}

@property PortsmouthConfigData *config;
@property WindowMoverController *windowMoverController;

-(id) initWithConfig:(PortsmouthConfigData*)configuration andWindowMoverController:(WindowMoverController*)controller;

@end
