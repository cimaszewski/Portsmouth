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
//  X11Util.m
//  Portsmouth


#import "X11Util.h"
#import <X11/Xutil.h>
#import <X11/Xatom.h>
#import "X11WeakLinker.h"

@implementation X11Util

static int X11ErrorHandler(Display *dpy, XErrorEvent *err) {
	char msg[256];
	
	//XGetErrorText(dpy, err->error_code, msg, sizeof(msg));
	[X11WeakLinker XGetErrorText:dpy code:err->error_code bufferRetuern:msg length:sizeof(msg)];
    printf("X11Error: %s (code: %d)\n", msg, err->request_code);
    
	return 0;
}

+(void)translateRectToX11:(NSRect*)rect
{
    rect->origin.y = [[[NSScreen screens] objectAtIndex:0] frame].size.height - rect->size.height - rect->origin.y;
}


+(void)setWindowPosition:(void *)window x: (int) x y: (int) y 
{
    Display *display;
    
    @try {
        
        //display = XOpenDisplay(NULL);
        display = [X11WeakLinker XOpenDisplay:NULL];
        
        if (!display) 
        {
            NSException *exception = [NSException exceptionWithName:@"SetWindowPositionFailedException" 
                                                             reason:@"Could not get the X11 display"
                                                           userInfo:nil];
            @throw exception;
        }
        
        //XSetErrorHandler(&X11ErrorHandler);  // is this really needed if we're handling exceptions with obj-c?
        [X11WeakLinker XSetErrorHandler:&X11ErrorHandler];
        
        // x and y are from the top left corner	
        //if (!XMoveWindow(display, *((Window *)window), x, y))
        if (![X11WeakLinker XMoveWindow:display window:*((Window *)window) x:x y:y])
        {
            NSException *exception = [NSException exceptionWithName:@"SetWindowPositionFailedException" 
                                                             reason:@"The X11 window reposition failed"
                                                           userInfo:nil];
            @throw exception;
        }
        
        // sync the display (blocking)
        //if (!XSync(display, False))
        if (![X11WeakLinker XSync:display discard:False])
        {
            NSException *exception = [NSException exceptionWithName:@"SetWindowPositionFailedException" 
                                                             reason:@"Could not resync the display"
                                                           userInfo:nil];
            @throw exception;;
        }
        
    }
    @catch (NSException *exception) {
        @throw;
    }
    @finally {
        if (display) {
            //XCloseDisplay(display);
            [X11WeakLinker XCloseDisplay:display];
        }
    }
	
	
}

// performs a basic check to see if the window is indeed resizable (doesn't check to see if we're resizing outside of the bounds of the window
// since I haven't figured out if that is able to be accomplished in OSX Accessibility yet).
+(BOOL) isWindowResizable:(void *)window
{
    Boolean isSettable = false;
    
    Display *display;
    XSizeHints hints;
    
    @try 
    {
        //display = XOpenDisplay(NULL);
        display = [X11WeakLinker XOpenDisplay:NULL];
        
        if (!display) 
        {
            NSException *exception = [NSException exceptionWithName:@"IsWindowResizableFailedException" 
                                                             reason:@"Could not get the X11 display"
                                                           userInfo:nil];
            @throw exception;
        }
        
        //XSetErrorHandler(&X11ErrorHandler);  // is this really needed if we're handling exceptions with obj-c?
        [X11WeakLinker XSetErrorHandler:&X11ErrorHandler];
        
        //if (!XGetNormalHints(display, *((Window *)window), &hints))
        if (![X11WeakLinker XGetNormalHints:display window:*((Window *)window) hints:&hints])
        {
            NSException *exception = [NSException exceptionWithName:@"IsWindowResizableFailedException" 
                                                             reason:@"Could not get the X11 window hints"
                                                           userInfo:nil];
            @throw exception;
        }
        
        
        isSettable = ((hints.min_width != hints.max_width) && (hints.min_height != hints.max_height));
        
    } 
    @catch (NSException *exception) 
    {
        @throw;
    }
    @finally 
    {
        if (display) 
        {
            //XCloseDisplay(display);
            [X11WeakLinker XCloseDisplay:display];
        }
    }
    
    return isSettable;
}

+(void)setWindowSize:(void *)window width: (unsigned int) width height: (unsigned int) height 
{
	
	Display *display;
    
    @try {
        //display = XOpenDisplay(NULL);
        display = [X11WeakLinker XOpenDisplay:NULL];
        
        if (!display) 
        {
            NSException *exception = [NSException exceptionWithName:@"SetWindowSizeFailedException" 
                                                             reason:@"Could not get the X11 display"
                                                           userInfo:nil];
            @throw exception;
        }
        
        //XSetErrorHandler(&X11ErrorHandler);  // is this really needed if we're handling exceptions with obj-c?
        [X11WeakLinker XSetErrorHandler:&X11ErrorHandler];
        
        XWindowAttributes attributes;
        //if(!XGetWindowAttributes(display, *((Window *)window), &attributes))
        if (![X11WeakLinker XGetWindowAttributes:display window:*((Window *)window) attributes:&attributes])
        {
            NSException *exception = [NSException exceptionWithName:@"SetWindowSizeFailedException" 
                                                             reason:@"Could not get X11 window attributes"
                                                           userInfo:nil];
            @throw exception;	
        }
        
        // will pass the size of the entire window including its decoration
        // we need to subtract that
        width -= attributes.x;
        height -= attributes.y;
        
        //if (!XResizeWindow(display, *((Window *)window), width, height))
        if (![X11WeakLinker XResizeWindow:display window:*((Window *)window) width:width height:height])
        {
            NSException *exception = [NSException exceptionWithName:@"SetWindowSizeFailedException" 
                                                             reason:@"Could not resize the X11 window"
                                                           userInfo:nil];
            @throw exception;
        }
        
        //if (!XSync(display, False))
        if (![X11WeakLinker XSync:display discard:False])
        {
            NSException *exception = [NSException exceptionWithName:@"SetWindowSizeFailedException" 
                                                             reason:@"Could not synchronize the X11 display"
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception) {
        @throw;
    }
    @finally {
        if (display) {
            //XCloseDisplay(display);
            [X11WeakLinker XCloseDisplay:display];
        }
    }
    
}

+(void *)getActiveWindow {
	Display* display = NULL;
    void *activeWindow;
    
    @try {
        
        //display = XOpenDisplay(NULL);
        display = [X11WeakLinker XOpenDisplay:NULL];
        
        if (!display) {
            NSException *exception = [NSException exceptionWithName:@"GetActiveWindowFailedException" 
                                                             reason:@"Could not get the X11 display"
                                                           userInfo:nil];
            @throw exception;
        }
        
        //XSetErrorHandler(&X11ErrorHandler);
        [X11WeakLinker XSetErrorHandler:&X11ErrorHandler];
        
        Window root = DefaultRootWindow(display);
        
        // following are for the params that are not used
        int not_used_int;
        unsigned long not_used_long;
        
        Atom actual_type = 0;
        unsigned char *prop_return = NULL;
        
        //if(XGetWindowProperty(display, root, XInternAtom(display, "_NET_ACTIVE_WINDOW", False), 0, 0x7fffffff, False,
        //                      XA_WINDOW, &actual_type, &not_used_int, &not_used_long, &not_used_long,
        //                      &prop_return) != Success)
        if ([X11WeakLinker XGetWindowProperty:display window:root property:[X11WeakLinker XInternAtom:display atomName:"_NET_ACTIVE_WINDOW" onlyIfExists:False]
                                       offset:0 length:0x7fffffff delete:False reqType:XA_WINDOW actual:&actual_type
                                 actualFormat:&not_used_int nitems:&not_used_long bytes:&not_used_long prop:&prop_return] != Success)
        
        {
            NSException *exception = [NSException exceptionWithName:@"GetActiveWindowFailedException" 
                                                             reason:@"Could not get the X11 active window property"
                                                           userInfo:nil];
            @throw exception;
        }
        
        if (prop_return == NULL || *((Window *) prop_return) == 0) {
            NSException *exception = [NSException exceptionWithName:@"GetActiveWindowFailedException" 
                                                             reason:@"Could not get the X11 active window"
                                                           userInfo:nil];
            @throw exception;
        }
        
        activeWindow = (void *) prop_return;
    }
    @catch (NSException *exception) {
        @throw;
    }
    @finally {
        //XCloseDisplay(display);
        [X11WeakLinker XCloseDisplay:display];
    }
    
    return activeWindow;
	
}

+(NSRect) getWindowGeometry:(void *) window {
    
    NSRect rect;
	Display *display = NULL;
    int x = 0, y = 0;
    
    @try {
        //display = XOpenDisplay(NULL);
        display = [X11WeakLinker XOpenDisplay:NULL];
        
        if (!display) {
            NSException *exception = [NSException exceptionWithName:@"GetWindowGeometryFailedException" 
                                                             reason:@"Could not get the X11 display"
                                                           userInfo:nil];
            @throw exception;
        }
        
        //XSetErrorHandler(&X11ErrorHandler);
        [X11WeakLinker XSetErrorHandler:&X11ErrorHandler];
        
        Window root = DefaultRootWindow(display);
        XWindowAttributes attributes;
        
        //if(!XGetWindowAttributes(display, *((Window *)window), &attributes))
        if (![X11WeakLinker XGetWindowAttributes:display window:*((Window *)window) attributes:&attributes])
        {
            NSException *exception = [NSException exceptionWithName:@"GetWindowGeometryFailedException" 
                                                             reason:@"Could not get X11 window attributes"
                                                           userInfo:nil];
            @throw exception;
        }
        
        Window not_used_window;
        //if(!XTranslateCoordinates(display, *((Window *)window), root, -attributes.border_width, -attributes.border_width, &x, &y, &not_used_window))
        if (![X11WeakLinker XTranslateCoordinates:display srcWindow:*((Window *)window) destWindow:root srcX:-attributes.border_width srcY:-attributes.border_width dextX:&x destY:&y child:&not_used_window])
        {
            NSException *exception = [NSException exceptionWithName:@"GetWindowGeometryFailedException" 
                                                             reason:@"Could not translate the display coordinates"
                                                           userInfo:nil];
            @throw exception;
        }
        
        // the height returned is without the window manager decoration - the OSX top bar with buttons, window label and stuff
        // so we need to add it to the height as well because the WindowSize expects the full window
        // the same might be potentially apply to the width
        rect.size.width = attributes.width + attributes.x;
        rect.size.height = attributes.height + attributes.y;
        
        rect.origin.x += x;
        rect.origin.y += y;
        
        rect.origin.x -= attributes.x;    
        rect.origin.y -= attributes.y;
        
    }
    @catch (NSException *exception) {
        @throw;
    }
    @finally {
        //XCloseDisplay(display);
        [X11WeakLinker XCloseDisplay:display];
    }

	
    return rect;
		
}

+(void) freeRef:(void *)ref {
    if (ref) {
        //XFree(ref);
        [X11WeakLinker XFree:ref];
    }
}

@end
