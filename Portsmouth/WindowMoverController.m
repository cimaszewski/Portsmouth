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
//  WindowMoverController.m
//  Portsmouth

#import "WindowMoverController.h"
#import "RoundedCornerOverlayWindow.h"
#import "WindowMoverCell.h"
#import "WindowMoverView.h"
#import "AccessibilityUtil.h"
#import "X11Util.h"

@implementation WindowMoverController

@synthesize config = _config;
@synthesize view = _view;
@synthesize window = _window;
@synthesize isWindowSelected = _isWindowSelected;

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,
                       void *userData)
{
    WindowMoverController* controller = (__bridge WindowMoverController *)userData;
    
    if(GetEventKind(theEvent) == kEventHotKeyPressed)
    {
            EventHotKeyID hkCom;
            GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,
                              sizeof(hkCom),NULL,&hkCom);
            int l = hkCom.id;
        
            if (l == 1)
            {
                [controller openModal];
            }
    
    }
    else if(GetEventKind(theEvent) == kEventHotKeyReleased)
    {
        if (!controller.isWindowSelected)
        {
            EventHotKeyID hkCom;
            GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,
                              sizeof(hkCom),NULL,&hkCom);
            int l = hkCom.id;
            
            if (l == 1)
            {
                [controller closeModalWithSelection:NO];
            }
        }
    }
    
    return noErr;
}




-(id) initWithConfig:(PortsmouthConfigData*)configuration
{
    if (![super init]) {
		return nil;
    }
    
    
    _selfRef = CFBridgingRetain(self);
    
	_config = configuration;
    
    const EventTypeSpec hotKeyEvents[] = {{kEventClassKeyboard,kEventHotKeyPressed},{kEventClassKeyboard,kEventHotKeyReleased}};
    InstallApplicationEventHandler(NewEventHandlerUPP(hotKeyHandler),GetEventTypeCount(hotKeyEvents),hotKeyEvents,(void*)_selfRef,NULL);
    
    [self setupHotKeyBinding];
    
    return self;
}



-(void)setupHotKeyBinding
{
	if (_showModalHotKeyRef == nil && _config != nil && _config.keyCombo.code != 0 && _config.keyCombo.flags != 0)
	{
		_hotKeyID.signature='smhk';
		_hotKeyID.id=1;
	
		RegisterEventHotKey((UInt32)_config.keyCombo.code, (UInt32)SRCocoaToCarbonFlags(_config.keyCombo.flags), _hotKeyID,
                        GetApplicationEventTarget(), 0, &_showModalHotKeyRef);
	}
}

-(void)removeHotKeyBinding
{
    if (_showModalHotKeyRef)
    {
        OSStatus error = UnregisterEventHotKey(_showModalHotKeyRef);
        if(error){
            //handle error
        }
        _showModalHotKeyRef = nil;
    }
}

-(void) moveSelectionWithArrowKey:(ArrowKey) direction
{
    NSInteger row, column;
    WindowMoverCell *currentHighlightedCell;
    
    for (int i = 0; i < [[_view cells] count]; i++)
    {
        WindowMoverCell *cell = [[_view cells] objectAtIndex:i];
        
        if ([cell isHighlighted])
        {
            [_view getRow:&row column:&column ofCell:cell];
            [cell setHighlighted:NO];
            currentHighlightedCell = cell;
            break;
        }
    }
    
    if (!currentHighlightedCell)
    {
        row = 1;
        column = 1;
    }
    else
    {
        switch (direction)
        {
            case kUp:
                if (row > 0) { row--; }
                break;
            case kDown:
                if (row < 2) { row++; }
                break;
            case kLeft:
                if (column > 0) { column--; }
                break;
            case kRight:
                if (column < 2) { column++; }
                break;
        }
    }
    
    WindowMoverCell *cell = [_view cellAtRow:row column:column];
    
    [cell setHighlighted:YES];
    [self hoverEventDetectedForTarget:[cell overlayTarget]];
}

// We'll get the active window before opening the popup;
// maybe we can put the name of the window on the popup;
// maybe we'll eliminate the popup via mouse
// or we eliminate the the idea of selecting the arrows with keystrokes

- (void)openModal
{

    log4Debug(@"Pause Counter.... %d", _pauseCounter);
       
    if (_pauseCounter > 1)
    {
        return;
    }
    
    //[self tearDownAccessibilityKeys];
    
    if (!_focusedWindow && !_x11Window)
    {
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
        
        if (_focusedWindow != nil)
        {
            _targetController = [[WindowTargetController alloc] initWithAXWindow:_focusedWindow screen:[NSScreen mainScreen] configuration:self.config];
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
                        _targetController = [[WindowTargetController alloc] initWithX11Window:_x11Window screen:[NSScreen mainScreen] configuration:self.config];
                    }
                }
            }
        }
    }


    if (_focusedWindow || _x11Window)
	{
		
        _isWindowSelected = YES;
        
        NSRect windowRect = NSZeroRect;
        NSRect viewRect = NSZeroRect;
        
        
        
        windowRect.size = NSMakeSize(280, 280);
        viewRect.size = NSMakeSize(248, 248);
        
        // rotate through the screens
        if (_screenNumber >= [[NSScreen screens] count])
        {
            _screenNumber = 0;
        }
        [_targetController setScreen:[[NSScreen screens] objectAtIndex:_screenNumber]];
        NSRect screenRect = [[[NSScreen screens] objectAtIndex:_screenNumber++] frame];
        
        windowRect.origin.x = screenRect.origin.x + ((screenRect.size.width-windowRect.size.width)/2);
        windowRect.origin.y = screenRect.origin.y + ((screenRect.size.height-windowRect.size.height)/2);
        
        _window = [[RoundedCornerOverlayWindow alloc] initWithContentRect:windowRect
                                                          backgroundColor:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:.25]
                                                              borderColor:nil
                                                              borderWidth:0.0f
                                                              borderStyle:noborder
                                                             cornerRadius:20.0f
                                                       ignoresInteraction:NO];
        
        
        _view = [[WindowMoverView alloc] initWithFrame:viewRect];
        
        [_view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable | NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
        
        [_view setTranslatesAutoresizingMaskIntoConstraints:YES];
        
        [_view setAutoresizesSubviews:YES];
        
        [_view setFrameOrigin:NSMakePoint(
                                          (NSWidth([_window frame]) - NSWidth([_view frame])) / 2,
                                          (NSHeight([_window frame]) - NSHeight([_view frame])) / 2
                                          )];
        [_view setWindowMover:self];
        [[_window contentView] addSubview:_view];
        [_window makeFirstResponder:self];
        
        
        [_window setFrame:windowRect display:YES animate:NO];
        
        [[NSRunningApplication currentApplication] activateWithOptions: NSApplicationActivateIgnoringOtherApps];
        
        ((WindowMoverCell *)[_view cellAtRow:0 column:0]).overlayTarget = kTopLeftWindowTarget;
        ((WindowMoverCell *)[_view cellAtRow:0 column:1]).overlayTarget = kTopWindowTarget;
        ((WindowMoverCell *)[_view cellAtRow:0 column:2]).overlayTarget = kTopRightWindowTarget;
        ((WindowMoverCell *)[_view cellAtRow:1 column:0]).overlayTarget = kLeftWindowTarget;
        ((WindowMoverCell *)[_view cellAtRow:1 column:1]).overlayTarget = kFullScreenWindowTarget;
        ((WindowMoverCell *)[_view cellAtRow:1 column:2]).overlayTarget = kRightWindowTarget;
        ((WindowMoverCell *)[_view cellAtRow:2 column:0]).overlayTarget = kBottomLeftWindowTarget;
        ((WindowMoverCell *)[_view cellAtRow:2 column:1]).overlayTarget = kBottomWindowTarget;
        ((WindowMoverCell *)[_view cellAtRow:2 column:2]).overlayTarget = kBottomRightWindowTarget;
        
        
            
        [_window makeKeyAndOrderFront:_window];
        

    }
    else
    {
        _isWindowSelected = NO;
        
        NSRect windowRect = NSZeroRect;
        NSRect viewRect = NSZeroRect;
        
        
        
        windowRect.size = NSMakeSize(332, 120);
        viewRect.size = NSMakeSize(310, 38);
        
        NSRect screenRect = [[NSScreen mainScreen] frame];
        
        windowRect.origin.x = screenRect.origin.x + ((screenRect.size.width-windowRect.size.width)/2);
        windowRect.origin.y = screenRect.origin.y + ((screenRect.size.height-windowRect.size.height)/2);
        
        _window = [[RoundedCornerOverlayWindow alloc] initWithContentRect:windowRect
                                                          backgroundColor:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:.25]
                                                              borderColor:nil
                                                              borderWidth:0.0f
                                                              borderStyle:noborder
                                                             cornerRadius:20.0f
                                                       ignoresInteraction:NO];
        
        
        NSTextField *view = [[NSTextField alloc] initWithFrame:viewRect];
        
        [view setStringValue:@"No Window Selected"];
        [view setTextColor:[NSColor whiteColor]];
        [view setFont:[NSFont fontWithName:@"Arial Bold" size:30]];
        [view setBezeled:NO];
        [view setDrawsBackground:NO];
        [view setEditable:NO];
        [view setSelectable:NO];
        [view setAlignment:NSCenterTextAlignment];
        
        [view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable | NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
        
        [view setTranslatesAutoresizingMaskIntoConstraints:YES];
        
        [view setAutoresizesSubviews:YES];
        
        [view setFrameOrigin:NSMakePoint(
                                          (NSWidth([_window frame]) - NSWidth([view frame])) / 2,
                                          (NSHeight([_window frame]) - NSHeight([view frame])) / 2
                                          )];
        
        [[_window contentView] addSubview:view];
        [_window makeFirstResponder:self];
        
        
        [_window setFrame:windowRect display:YES animate:NO];
        
        [_window makeKeyAndOrderFront:_window];
        
    }
    
    
}

-(void) escapePressHandler
{
    
    [self closeModalWithSelection:NO];
}

-(void)pause
{
    log4Debug(@"WindowMoverController is Paused...");
    [self removeHotKeyBinding];
    if (_pauseCounter > 1)
    {
        [self closeModalWithSelection:NO];
    }
}

-(void)unpause
{
    log4Debug(@"WindowMoverController is unPaused...");
    [self setupHotKeyBinding];
}

-(void) closeModalWithSelection:(Boolean) isSelected
{
    _screenNumber = 0;
    
    @try
    {
        if (isSelected && (_focusedWindow || _x11Window))
        {
            [_targetController moveWindow];
        }
        
    }
    @catch (NSException *exception)
    {
        log4ErrorWithException(@"Exception thrown: (%@) %@", exception, exception.name, exception.reason);
    }
    @finally
    {
        [_window setFrame:NSZeroRect display:NO];
        _window = nil;
        _view = nil;
        _targetController = nil;
        
        if (_x11Window)
        {
            [X11Util freeRef:_x11Window];
            _x11Window = nil;            
        }
        
        if (_focusedWindow != nil)
        {
            
            [AccessibilityUtil freeRef:_focusedWindow];
            _focusedWindow = nil;
            
        }
        
        
        if (!_pauseCounter)
        {
            [NSApp hide:nil];
        }
    }
}

-(void)hoverEventDetectedForTarget:(WindowTargetConstant)target
{
    _targetController.targetConstant = target;
    [_targetController displayOverlay];
}

-(void)clickEventDetectedForTarget:(WindowTargetConstant)target
{
    [self closeModalWithSelection:YES];
}

-(void) dealloc
{
    if (_selfRef)
    {
        CFBridgingRelease(_selfRef);
    }
    
    [self removeHotKeyBinding];
}




-(void)keyDown:(NSEvent *)theEvent
{
    if (![theEvent isARepeat])
    {
        if ([self isWindowSelected])
        {
            switch ([theEvent keyCode]) {
                case 36: // enter key
                case 49: // space bar
                    [self closeModalWithSelection:YES];
                    break;
                case 53: //escape key
                    [self closeModalWithSelection:NO];
                    break;
                case 123: //left
                    [self moveSelectionWithArrowKey:kLeft];
                    break;
                case 124: //right
                    [self moveSelectionWithArrowKey:kRight];
                    break;
                case 125: //down
                    [self moveSelectionWithArrowKey:kDown];
                    break;
                case 126: //up
                    [self moveSelectionWithArrowKey:kUp];
                    break;
            }
        }
        else
        {
            switch ([theEvent keyCode]) {
                case 53: //escape ket
                    [self closeModalWithSelection:NO];
                    break;
            }
        }
    }
}


-(void)flagsChanged:(NSEvent *)theEvent {
    
    if (_focusedWindow && !_x11Window)
    {
        if ([AccessibilityUtil canSetFullscreen:_focusedWindow])
        {
            [_view toggleAltImages:(([theEvent modifierFlags] & NSAlternateKeyMask) == NSAlternateKeyMask)];
        }
    }
}

-(void)mouseMoved:(NSEvent *)theEvent {
    NSInteger row;
    NSInteger column;
    
    NSPoint mouseLoc = [_view convertPoint:[theEvent locationInWindow] fromView:nil];
    
    [_view getRow:&row column:&column forPoint:mouseLoc];
    
    WindowMoverCell *hoverCell = [_view cellAtRow:row column:column];
    
    if (hoverCell != nil)
    {
        
        [hoverCell setHighlighted:YES];
        
        [self hoverEventDetectedForTarget:hoverCell.overlayTarget];
        
        
        for (int i = 0; i < [[_view cells] count]; i++)
        {
            WindowMoverCell *cell = [[_view cells] objectAtIndex:i];
            
            if (hoverCell != cell)
            {
                [cell setHighlighted:NO];
            }
        }
    }
    
    
    
}

@end
