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
//  WindowDragHandler.m
//  Portsmouth


#import "WindowDragEventController.h"
#import "AccessibilityUtil.h"
#import "X11Util.h"

@implementation WindowDragEventController

@synthesize config = _config;

static void windowDragCallback(AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void* contextData)
{
    // handle the notification appropriately
    WindowDragEventController *controller = (__bridge WindowDragEventController*)contextData;
    
    [controller performEventForWindowDrag];
}


-(void)performEventForWindowDrag
{
    [self doesNotRecognizeSelector:_cmd];
}

-(void)performEventForMouseRelease
{
    [self doesNotRecognizeSelector:_cmd];
}



-(void)globalMouseClickHandler
{
    if (_pauseCounter)
    {
        return;
    }
    
    _isMouseReleased = NO;
    
    @try 
    {
        // try to get the active window via accessibility
        _focusedWindow = [AccessibilityUtil getActiveWindow];
    }
    @catch (NSException *exception) 
    {
        // Must be an X11 or another type of window
        log4Debug(@"Couldn't get the window via accessibility.");
        _focusedWindow = nil;
    }
        
    // if the _focusedWindow exists from the accessibility API
    if (_focusedWindow != nil) 
    {
        @try {
           
            _initialWindowPosition = [AccessibilityUtil getWindowPosition:_focusedWindow];
            
            for (NSRunningApplication *currApp in [[NSWorkspace sharedWorkspace] runningApplications]) 
            {
                
                // if the current iteration is the actvie application
                if ([currApp isActive]) 
                {
                    if ([currApp processIdentifier] == [[NSRunningApplication currentApplication] processIdentifier])
                    {
                        // Portsmouth windows should be ignored
                        break;
                    }
                    
                    _appElement = AXUIElementCreateApplication([currApp processIdentifier]);
                    
                    log4Debug(@"* %@ %d  %d", [currApp localizedName], [currApp processIdentifier], [NSRunningApplication currentApplication].processIdentifier);
                    
                    // Create the observer for the current process
                    // observer should be class level and removed when the mouse up occurs
                    if (AXObserverCreate([currApp processIdentifier], windowDragCallback, &_observer) == kAXErrorSuccess) 
                    {
                        
                                                
                        // add observer run loop to the main run loop
                        CFRunLoopAddSource(CFRunLoopGetCurrent(), 
                                           AXObserverGetRunLoopSource(_observer), kCFRunLoopCommonModes);
                        
                        // add a notification for when the focused window is moved
                        AXObserverAddNotification( _observer, _appElement, kAXMovedNotification, (__bridge void*)self );

                    }
                }
            }
        }
        @catch (NSException *exception) 
        {
            log4ErrorWithException(@"Exception occurred attempting to perform accessibility click handler: (%@) %@", exception, exception.name, exception.reason);
        }
        
        
    }
    else  // window not available via accessibility
    {
        if (self.config.isX11SupportEnabled)  // check to see if X11 support is enabled
        {
            // try to see if xquartz is running (mountain lion requires xquartz...)
            NSArray *array = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"org.macosforge.xquartz.X11"];
            
            if (array && [array count] > 0) {
                
                log4Debug(@"Must be an X11 window");
                
                @try
                {
                    _x11Window = [X11Util getActiveWindow];
                }
                @catch (NSException *exception)
                {
                    _x11Window = NULL;
                }
                
                
                if (_x11Window)
                {
                    @try
                    {
                        _initialWindowPosition = [X11Util getWindowGeometry:_x11Window].origin;
                        
                        //[X11WindowUtil translatePointFromX11:&_initialWindowPosition];
                        
                        _x11WindowMoved = NO;
                        
                        log4Debug(@"X11 window geometry: x: %f, y: %f", _initialWindowPosition.x, _initialWindowPosition.y);
                    }
                    @catch (NSException *exception)
                    {
                        log4Debug(@"Exception occurred attempting to perform X11 click handler: (%@) %@", exception.name, exception.reason);
                    }
                    
                    
                    
                }
            }
        }
    }

}

-(void)globalMouseDragHandler
{
    if (_x11Window) 
    {
        @try 
        {
            NSRect geometry = [X11Util getWindowGeometry:_x11Window];
            
            //[X11WindowUtil translatePointFromX11:&geometry.origin];
            
            if (!_x11WindowMoved && 
                (geometry.origin.x != _initialWindowPosition.x || geometry.origin.y != _initialWindowPosition.y))
            {
                log4Debug(@"X11 Window has moved: x: %f, y: %f", geometry.origin.x, geometry.origin.y);
                _x11WindowMoved = YES;
            }
            
            if (_x11WindowMoved) 
            {
                [self performEventForWindowDrag];
            }
        }
        @catch (NSException *exception) 
        {
            log4ErrorWithException(@"Exception occurred attempting to perform X11 drag handler: (%@) %@", exception, exception.name, exception.reason);
        }
        
    }
}

-(void) globalMouseReleaseHandler 
{
    log4Debug(@"Mouse UP!");
    
    _isMouseReleased = YES;
    
    [self performEventForMouseRelease];
    
    if (_x11Window) 
    {
        [X11Util freeRef:_x11Window];
        _x11Window = nil;
        _initialWindowPosition = NSZeroPoint;
        _x11WindowMoved = NO;
        
    }
    
    if (_focusedWindow != nil) 
    {
        [AccessibilityUtil freeRef:_focusedWindow];
        _focusedWindow = nil;
        
        if (_observer)
        {
            log4Debug(@"Freeing observer");
            AXObserverRemoveNotification( _observer, _appElement, kAXMovedNotification);
            CFRelease(_observer);
            _observer = nil;
        }
            
        if (_appElement)
        {
            log4Debug(@"Freeing appelement");
            CFRelease(_appElement);
            _appElement = nil;
        }
    }
}

// pause event that does the same thing as the mouse up, but doesn't do any moving junk
-(void)pause
{
    log4Debug(@"WindowDragEventController is Paused...");
    _isMouseReleased = YES;
    
    if (_x11Window)
    {
        [X11Util freeRef:_x11Window];
        _x11Window = nil;
        _initialWindowPosition = NSZeroPoint;
        _x11WindowMoved = NO;
        
    }
    
    if (_focusedWindow != nil)
    {
        [AccessibilityUtil freeRef:_focusedWindow];
        _focusedWindow = nil;
        
        if (_observer)
        {
            AXObserverRemoveNotification( _observer, _appElement, kAXMovedNotification);
            CFRelease(_observer);
            _observer = nil;
        }
        
        if (_appElement)
        {
            CFRelease(_appElement);
            _appElement = nil;
        }
    }
}

-(void)unpause
{
    // not needed...
}

// initialize the global click handler
-(id)initWithConfig:(PortsmouthConfigData *)configuration
{
    if (self = [super init]) 
    {
        self.config = configuration;
        
    
        _clickEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:(NSLeftMouseDownMask)
                                                                    handler:^(NSEvent *incomingEvent) 
                              {
                                  
                                  [self globalMouseClickHandler];
                                  
                              }];
        
        
        
        _dragEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:(NSLeftMouseDraggedMask)
                                                                   handler:^(NSEvent *incomingEvent) 
                             {
                                 
                                 [self globalMouseDragHandler]; 
                                 
                             }];
        
        
        _releaseEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:(NSLeftMouseUpMask)
                                                                      handler:^(NSEvent *incomingEvent) 
                                {
                                    
                                    [self globalMouseReleaseHandler];
                                    
                                }];
    }
    
    return self;
}

-(void) dealloc
{
    if (_clickEventMonitor)
    {
        [NSEvent removeMonitor:_clickEventMonitor];
        _clickEventMonitor = nil;
    }
    
    if (_dragEventMonitor)
    {
        [NSEvent removeMonitor:_dragEventMonitor];
        _dragEventMonitor = nil;
    }
    
    if (_releaseEventMonitor)
    {
        [NSEvent removeMonitor:_releaseEventMonitor];
        _releaseEventMonitor = nil;
    }

}

@end
