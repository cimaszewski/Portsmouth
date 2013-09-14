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
//  WindowSnapController.m
//  Portsmouth


#import "WindowSnapController.h"
#import "AccessibilityUtil.h"
#import "X11Util.h"

@implementation WindowSnapController


-(void)cancelTarget
{
    _isCancelled = YES;
    [_targetController setTargetConstant:kNoWindowTarget];
    [_targetController displayOverlay];
    
    if (_escapeEventMonitor)
    {
        [NSEvent removeMonitor:_escapeEventMonitor];
        _escapeEventMonitor = nil;
    }
}

-(id)initWithConfig:(PortsmouthConfigData *)configuration
{
    if (![super initWithConfig:configuration]) {
		return nil;
    }
    
    
    return self;
}

-(void)performEventForWindowDrag
{
    // if the mouse has already been released (this is due to an issue where the drag event is fired after the release
    if (_isMouseReleased)
    {
        return;
    }
    
    _escapeEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:(NSKeyDownMask)
                                                                handler:^(NSEvent *incomingEvent)
                          {
                              
                              [self cancelTarget];
                              
                          }];

    
    _isCancelled = NO;
    
    log4Debug(@"Performing Window Drag!!!");
    
    NSPoint mouseLoc;
    mouseLoc = [NSEvent mouseLocation]; //get current mouse position
    log4Debug(@"Mouse location: %f %f", mouseLoc.x, mouseLoc.y);
    
    if (_mouseLocation.x != mouseLoc.x || _mouseLocation.y != mouseLoc.y) 
    {
        _mouseLocation = mouseLoc;
    } 
    else 
    {
        return;
    }
    
    
    //  TODO: figure out a more elegant solution
    // possibly an array of all of the rects and iterating through them
    for (NSScreen *screen in [NSScreen screens]) 
    {
        NSRect adjustedFrame = [screen frame];
        
        adjustedFrame.size.width += 2;
        adjustedFrame.size.height += 2;
        adjustedFrame.origin.x -= 1;
        adjustedFrame.origin.y -= 1;
        
        if (NSPointInRect(mouseLoc, adjustedFrame)) 
        {
            
            if (_targetController == nil) {
                if (_focusedWindow != nil)
                {
                    _targetController = [[WindowTargetController alloc] initWithAXWindow:_focusedWindow screen:screen configuration:self.config];
                }
                else if (_x11Window != nil)
                {
                    _targetController = [[WindowTargetController alloc] initWithX11Window:_x11Window screen:screen configuration:self.config];
                }
            }
            else
            {
                [_targetController setScreen:screen];
            }
            
            if (_targetController != nil)
            {
                [_targetController setMousePoint:mouseLoc];
                _targetController.focusedWindow = _focusedWindow;
                _targetController.x11Window = _x11Window;
            }
        
        }
        
        
    }
    
    
    [_targetController displayOverlay];

}

-(void)performEventForMouseRelease
{
    if (_escapeEventMonitor)
    {
        [NSEvent removeMonitor:_escapeEventMonitor];
        _escapeEventMonitor = nil;
    }
    
    @try 
    {
        if (!_isCancelled && (_focusedWindow || (_x11Window && _x11WindowMoved)))
        {
            [_targetController moveWindow];
        }
        _isCancelled = YES;
        
    }
    @catch (NSException *exception) 
    {
        log4ErrorWithException(@"Exception thrown: (%@) %@", exception, exception.name, exception.reason);
    }
    @finally 
    {
        
        _targetController = nil;
    }
    
    
    
}


@end
