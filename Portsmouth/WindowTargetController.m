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
//  WindowTargetController.m
//  Portsmouth


#import "WindowTargetController.h"
#import "AccessibilityUtil.h"
#import "X11Util.h"
#import "RoundedCornerOverlayWindow.h"
#import <Carbon/Carbon.h>

// exposing the carbon function for getting the menu bar height
extern short GetMBarHeight(void);

@implementation WindowTargetController

@synthesize x11Window = _x11Window;
@synthesize focusedWindow = _focusedWindow;
@synthesize targetConstant = _targetConstant;


-(id)initWithAXWindow:(CFTypeRef)window screen:(NSScreen*)screen configuration:(PortsmouthConfigData *)configuration
{
    if (self = [super init])
    {
        _config = configuration;
        
        _focusedWindow = window;
        
        [self setScreen:screen];
        
        @try
        {
            if ([AccessibilityUtil isCurrentlyFullscreened:_focusedWindow])
            {
                
                
                [AccessibilityUtil removeFullscreen:_focusedWindow];
				
				// There has to be a more graceful way to do this than sleeping this thread
				// The current animation takes a second to remove the full screen, so we
				// are waiting the second before returning.
				usleep(1000000);
                
            }
        }
        @catch (NSException *e)
        {
            // ignored; if the removal of fullscreen fails we really shouldn't care
        }
    }
    
    return self;
}

-(id)initWithX11Window:(void*)window screen:(NSScreen*)screen configuration:(PortsmouthConfigData *)configuration
{
    if (self = [super init])
    {
        _config = configuration;
        
        _x11Window = window;
        
        [self setScreen:screen];
    }
    
    return self;
}

-(void)setScreen:(NSScreen*)screen
{
    _screen = screen;
    
    if (_focusedWindow && ![AccessibilityUtil isWindowResizable:_focusedWindow])
    {
        NSRect geometry = [AccessibilityUtil getWindowGeometry:_focusedWindow];
        
        _data = [[WindowTargetData alloc] initWithScreenRect:[screen frame]
                                                visibleRect:[screen visibleFrame]
                                           staticWindowSize:geometry.size];
    }
    else if (!_focusedWindow && _x11Window && ![X11Util isWindowResizable:_x11Window])
    {
        NSRect geometry = [X11Util getWindowGeometry:_x11Window];
        
        _data = [[WindowTargetData alloc] initWithScreenRect:[screen frame]
                                                visibleRect:[screen visibleFrame]
                                           staticWindowSize:geometry.size];
    }
    else
    {
        _data = [[WindowTargetData alloc] initWithScreenRect:[screen frame]
                                                visibleRect:[screen visibleFrame]];
    }
    
    _hotzones = [[WindowHotzoneData alloc] initWithScreenRect:[screen frame] configuration:_config];
}

-(void)setMousePoint:(NSPoint)point
{
    _targetConstant = [_hotzones fetchTargetForHotzonePoint:point];
    
    if (_targetConstant == kTopWindowTarget && _config.defaultTopToFullScreen)
    {
        _targetConstant = kFullScreenWindowTarget;
    }
    else if (_targetConstant == kBottomWindowTarget && _config.defaultTopToFullScreen)
    {
        _targetConstant = kNoWindowTarget;
    }
}

-(void)displayOverlay
{
    if (_targetConstant != kNoWindowTarget)
    {
        _windowRect = [_data fetchWindowTarget:_targetConstant];
    }
    else
    {
        _windowRect = NSZeroRect;
    }
    
    if (_focusedWindow && ![AccessibilityUtil isWindowResizable:_focusedWindow] && !NSEqualRects(_windowRect, NSZeroRect))
    {
        NSRect geometry = [AccessibilityUtil getWindowGeometry:_focusedWindow];
        
        _windowRect.size.width = geometry.size.width;
        _windowRect.size.height = geometry.size.height;
    }
    
    if (_window == nil && !NSEqualRects(_windowRect, NSZeroRect) && _config.displayTargetOverlay)
    {
        
        RoundedCornerOverlayWindow *trackingWin;
        
        trackingWin = [[RoundedCornerOverlayWindow alloc] initWithContentRect:_windowRect
                                                              backgroundColor:_config.overlayBackgroundColor
                                                                  borderColor:_config.overlayBorderColor
                                                                  borderWidth:_config.borderWidth
                                                                  borderStyle:_config.borderStyle
                                                                 cornerRadius:_config.cornerRadius
                                                           ignoresInteraction:YES];
        
        _window = trackingWin;
    }
    else if (_window != nil && !NSEqualRects(_windowRect, NSZeroRect))
    {
        [_window setFrame:_windowRect display:YES animate:NO];
    }
    else if (_window != nil)
    {
        [_window setFrame:_windowRect display:NO];
        _window = nil;
    }
}

-(void) moveWindow
{
    @try
    {
        if (!NSEqualRects(_windowRect, NSZeroRect))
        {
            _moveRect = _windowRect;
            _moveRect.origin.y = [[[NSScreen screens] objectAtIndex:0] frame].size.height  - _moveRect.origin.y - _moveRect.size.height;
            
			
            if (_focusedWindow) {
				BOOL isCurrentlyFullscreened = NO;
				
				@try {
					isCurrentlyFullscreened = [AccessibilityUtil isCurrentlyFullscreened:_focusedWindow];
				}
				@catch (NSException *exception) {
					isCurrentlyFullscreened = NO;
				}
                
                if (_targetConstant == kFullScreenWindowTarget &&
                        !isCurrentlyFullscreened &&
						// cocoa check here doesn't work for the drag component
                        //(_config.defaultFullScreenToLionFullScreen || [[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask))
						(_config.defaultFullScreenToLionFullScreen || (GetCurrentKeyModifiers() & optionKey))
                         
                    ) {
                    @try
                    {
                        [AccessibilityUtil setFullscreen:_focusedWindow];
                    }
                    @catch (NSException *e)
                    {
                        // set the position of the window
                        [AccessibilityUtil setWindowPosition:_focusedWindow x:_moveRect.origin.x y:_moveRect.origin.y];
                        
                        // set the size to get the proper animation
                        @try
                        {
                            [AccessibilityUtil setWindowSize:_focusedWindow width:_moveRect.size.width height:_moveRect.size.height];
                        }
                        @catch (NSException *exception)
                        {
                            //ignore the resize exception in case it's a window that can't be resized.
                        }
                        
                        // recalculated the origin if the application has a min size greater than the 
                        NSSize size = [AccessibilityUtil getWindowSize:_focusedWindow];
                        
                        if (size.height != _moveRect.size.height || size.width != _moveRect.size.width)
                        {
                            if (_targetConstant == kRightWindowTarget || _targetConstant == kTopRightWindowTarget || _targetConstant == kBottomRightWindowTarget)
                            {
                                _moveRect.origin.x += (_moveRect.size.width - size.width);
                            }
                            if (_targetConstant == kBottomRightWindowTarget || _targetConstant == kBottomLeftWindowTarget || _targetConstant == kBottomWindowTarget)
                            {
                                _moveRect.origin.y += (_moveRect.size.height - size.height);
                            }
                            if (_targetConstant == kTopWindowTarget || _targetConstant == kBottomWindowTarget || _targetConstant == kFullScreenWindowTarget)
                            {
                                _moveRect.origin.x = (_moveRect.size.width - size.width)/2;
                            }
                            if (_targetConstant == kLeftWindowTarget || _targetConstant == kRightWindowTarget || _targetConstant == kFullScreenWindowTarget)
                            {
                                _moveRect.origin.y = (_moveRect.size.height - size.height)/2;
                            }
                        }
                        
                        // reset the position due to menu bar/dock restrictions
                        [AccessibilityUtil setWindowPosition:_focusedWindow x:_moveRect.origin.x y:_moveRect.origin.y];
                        
                    }
                }
                else
                {
                    
                    // set the position of the window
                    [AccessibilityUtil setWindowPosition:_focusedWindow x:_moveRect.origin.x y:_moveRect.origin.y];
                    
                    // set the size to get the proper animation
                    @try
                    {
                        [AccessibilityUtil setWindowSize:_focusedWindow width:_moveRect.size.width height:_moveRect.size.height];
                    }
                    @catch (NSException *exception)
                    {
                        //ignore the resize exception in case it's a window that can't be resized.
                    }
                    
                    // recalculated the origin if the application has a min size greater than the
                    NSSize size = [AccessibilityUtil getWindowSize:_focusedWindow];
                    
                    if (size.height != _moveRect.size.height || size.width != _moveRect.size.width)
                    {
                        if (_targetConstant == kRightWindowTarget || _targetConstant == kTopRightWindowTarget || _targetConstant == kBottomRightWindowTarget)
                        {
                            _moveRect.origin.x += (_moveRect.size.width - size.width);
                        }
                        if (_targetConstant == kBottomRightWindowTarget || _targetConstant == kBottomLeftWindowTarget || _targetConstant == kBottomWindowTarget)
                        {
                            _moveRect.origin.y += (_moveRect.size.height - size.height);
                        }
                        if (_targetConstant == kTopWindowTarget || _targetConstant == kBottomWindowTarget || _targetConstant == kFullScreenWindowTarget)
                        {
                            _moveRect.origin.x = (_moveRect.size.width - size.width)/2;
                        }
                        if (_targetConstant == kLeftWindowTarget || _targetConstant == kRightWindowTarget || _targetConstant == kFullScreenWindowTarget)
                        {
                            _moveRect.origin.y = (_moveRect.size.height - size.height)/2;
                        }
                    }

                    
                    // reset the position due to menu bar/dock restrictions
                    [AccessibilityUtil setWindowPosition:_focusedWindow x:_moveRect.origin.x y:_moveRect.origin.y];
                }
            }
            else if (_x11Window)
            {
   

                
                NSRect screenUnionRect = NSZeroRect;
                NSRect geometry = NSZeroRect;
                
                screenUnionRect = [[[NSScreen screens] objectAtIndex:0] frame];
                for (NSScreen *screen in [NSScreen screens]) {
                    screenUnionRect = NSUnionRect(screenUnionRect, [screen frame]);
                }
                
                geometry = [X11Util getWindowGeometry:_x11Window];
                
                [X11Util translateRectToX11:&screenUnionRect];
                
                geometry.origin.x += screenUnionRect.origin.x;
                geometry.origin.y += screenUnionRect.origin.y;
                
                NSRect screenRect = [_screen frame];
                [X11Util translateRectToX11:&screenRect];
                
                NSRect visibleScreenRect = [_screen visibleFrame];
                [X11Util translateRectToX11:&visibleScreenRect];
                
                _moveRect = [_data fetchWindowTarget:_targetConstant];
                
                _moveRect.origin.x += -1 * screenUnionRect.origin.x + visibleScreenRect.origin.x - screenRect.origin.x;
                _moveRect.origin.y += screenUnionRect.origin.y + visibleScreenRect.origin.y - screenRect.origin.y;
                
                //_moveRect.origin.x -= screenUnionRect.origin.x;
                //_moveRect.origin.y -= screenUnionRect.origin.y;
                
            
                // if the top of the other screens are not equal to the primary and all of them are below the primary
				// this is only needed if there is more than one screen
                if (_screen == [[NSScreen screens] objectAtIndex:0] && [[NSScreen screens] count] > 1)
                {
                    // the menuBarHeight is returned as 0 since we don't have any menuBar Items for this application
                    // using the Carbon function for now
                    _moveRect.origin.y -= GetMBarHeight();
                }
            
                
                int count = 0;
                // moving the X11 window doesn't always work the first time, give it up to 10 attempts
                // we shouldn't have to check the size afterwards because if there is a max size smaller than the anticipated size,
                // we would've already known
                do
                {
                    [X11Util translateRectToX11:&_moveRect];
                    
                    [X11Util setWindowSize:_x11Window width:_moveRect.size.width height:_moveRect.size.height];
                    
                    [X11Util setWindowPosition:_x11Window x:_moveRect.origin.x y:_moveRect.origin.y];
                    usleep(50);
                    
                    geometry = [X11Util getWindowGeometry:_x11Window];
                    
                } while (count++ < 10 && (geometry.origin.x != _moveRect.origin.x || geometry.origin.y != _moveRect.origin.y || geometry.size.width != _moveRect.size.width || geometry.size.height != _moveRect.size.height));
            
            
            }
        
            
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception thrown: (%@) %@", exception.name, exception.reason);
    }
}

@end
