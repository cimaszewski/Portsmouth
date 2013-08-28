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
//  WindowDragHandler.h
//  Portsmouth


#import <Foundation/Foundation.h>
#import "PausableController.h"
#import "PortsmouthConfigData.h"

@interface WindowDragEventController : PausableController {
    NSEvent *_clickEventMonitor;
    NSEvent *_releaseEventMonitor;
    NSEvent *_dragEventMonitor;
    
    void *_x11Window;
    //NSRect _x11InitialGeometry;
    Boolean _x11WindowMoved;
   
    
    //CFTypeRef _initialWindowSize;
    NSPoint _initialWindowPosition;
    
    CFTypeRef _focusedWindow;
    CFTypeRef _appElement;
    AXObserverRef _observer;
    Boolean _isMouseReleased;
    
    PortsmouthConfigData *_config;
}

-(id)initWithConfig:(PortsmouthConfigData *)configuration;

-(void)performEventForWindowDrag;

-(void)performEventForMouseRelease;

@property PortsmouthConfigData *config;

@end
