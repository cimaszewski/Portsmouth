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
//  WindowMoverController.h
//  Portsmouth


#import <Foundation/Foundation.h>
#import "PausableController.h"
#import "PortsmouthConfigData.h"
#import "WindowTargetConstants.h"
#import "WindowTargetController.h"
#import "WindowMoverView.h"
#import "WindowMoverDelegate.h"
#import <Carbon/Carbon.h>

typedef enum {
    kUp,
    kDown,
    kLeft,
    kRight
} ArrowKey;

@interface WindowMoverController : PausableController <WindowMoverDelegate>
{
    void *_x11Window;
    CFTypeRef _focusedWindow;
    
    PortsmouthConfigData *_config;
    WindowMoverView *_view;
    NSWindow *_window;
    Boolean _isWindowOpen;
    
    WindowTargetController *_targetController;
    
    //Register the Hotkeys
    EventHotKeyRef _showModalHotKeyRef;
    
    EventHotKeyID _hotKeyID;
    
    CFTypeRef _selfRef;
    
    Boolean _isWindowSelected;
    int _screenNumber;

    NSEvent *_keyDownEventMonitor;
    NSEvent *_keyUpEventMonitor;
    
}

@property PortsmouthConfigData *config;
@property IBOutlet WindowMoverView *view;
@property IBOutlet NSWindow *window;
@property Boolean isWindowSelected;

-(void)openModal;
-(void) closeModalWithSelection:(Boolean) isSelected;
-(void) moveSelectionWithArrowKey:(ArrowKey) direction;

-(void)hoverEventDetectedForTarget:(WindowTargetConstant)target;
-(void)clickEventDetectedForTarget:(WindowTargetConstant)target;


-(void)keyDown:(NSEvent *)theEvent;
-(void)flagsChanged:(NSEvent *)theEvent;
-(void)mouseMoved:(NSEvent *)theEvent;

-(id) initWithConfig:(PortsmouthConfigData*)configuration;

@end
