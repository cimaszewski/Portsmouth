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
//  WindowTargetController.h
//  Portsmouth


#import <Foundation/Foundation.h>
#import "WindowTargetConstants.h"
#import "WindowTargetData.h"
#import "WindowHotzoneData.h"
#import "PortsmouthConfigData.h"

@interface WindowTargetController : NSObject
{
    NSWindow *_window;
    void *_x11Window;
    CFTypeRef _focusedWindow;
    CFTypeRef _appElement;
    
    WindowTargetData *_data;
    WindowHotzoneData *_hotzones;
    WindowTargetConstant _targetConstant;
    PortsmouthConfigData *_config;
    
    NSScreen *_screen;
        
    NSRect _windowRect;
    NSRect _moveRect;
}

-(id)initWithAXWindow:(CFTypeRef)window screen:(NSScreen*)screen configuration:(PortsmouthConfigData *)configuration;
-(id)initWithX11Window:(void*)window screen:(NSScreen*)screen configuration:(PortsmouthConfigData *)configuration;

-(void)setScreen:(NSScreen*)screen;
-(void)setMousePoint:(NSPoint)point;

-(void)displayOverlay;
-(void) moveWindow;


@property void *x11Window;
@property CFTypeRef focusedWindow;
@property WindowTargetConstant targetConstant;

@end
