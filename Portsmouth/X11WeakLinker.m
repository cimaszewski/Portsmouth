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
//  X11WeakLinker.m
//  Portsmouth


#import "X11WeakLinker.h"
#include <stdio.h>
#include <dlfcn.h>

@implementation X11WeakLinker

static void	*xlibRef = NULL;

static const char *xlib_path = "/usr/X11/lib/libX11.dylib";

// type define for the XGetErrorText function we'll be calling
typedef int(XGetErrorTextFunction) (Display *_display, int _code, char *_buffer_return, int _length);

// wrapper function for XGetErrorText
+(int) XGetErrorText:(Display *) display code:(int)code bufferRetuern:(char *)buffer_return length:(int)length
{
    static XGetErrorTextFunction *func = NULL;
	int errorTextReturn;
    
    if (!xlibRef)
		xlibRef = dlopen(xlib_path, RTLD_GLOBAL | RTLD_LAZY);
	
    if (!func) {
		func = (XGetErrorTextFunction *) dlsym(xlibRef, "XGetErrorText");
	}
    
    @try
    {
        if (xlibRef && func)
        {
           errorTextReturn = func(display, code, buffer_return, length); 
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"XGetErrorTextException"
                                                             reason:@"Could not execute Xlib function."
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception)
    {
        @throw;
    }
    
    
    return errorTextReturn;
}

// type define for the XOpenDisplay function we'll be calling
typedef Display*(XOpenDisplayFunction) (_Xconst char *_display_name);

// wrapper function for XOpenDisplay
+(Display*) XOpenDisplay:(_Xconst char *)display_name
{
    static XOpenDisplayFunction *func = NULL;
	Display *displayReturn;
    
    if (!xlibRef)
		xlibRef = dlopen(xlib_path, RTLD_GLOBAL | RTLD_LAZY);
	
    if (!func) {
		func = (XOpenDisplayFunction *) dlsym(xlibRef, "XOpenDisplay");
	}
    
    @try
    {
        if (xlibRef && func)
        {
            displayReturn = func(display_name);
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"XOpenDisplayException"
                                                             reason:@"Could not execute Xlib function."
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception)
    {
        @throw;
    }
    
    return displayReturn;
}

// type define for the XCloseDisplay function we'll be calling
typedef int(XCloseDisplayFunction) (Display *_display);

// wrapper function for XCloseDisplay
+(int)XCloseDisplay:(Display *)display
{
    static XCloseDisplayFunction *func = NULL;
	int closeReturn;
    
    if (!xlibRef)
		xlibRef = dlopen(xlib_path, RTLD_GLOBAL | RTLD_LAZY);
	
    if (!func) {
		func = (XCloseDisplayFunction *) dlsym(xlibRef, "XCloseDisplay");
	}
    
    @try
    {
        if (xlibRef && func)
        {
            closeReturn = func(display);
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"XCloseDisplayException"
                                                             reason:@"Could not execute Xlib function."
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception)
    {
        @throw;
    }
    
    
    return closeReturn;
}


// type define for the XSetErrorHandler function we'll be calling
typedef XErrorHandler(XSetErrorHandlerFunction) (XErrorHandler _handler);

// wrapper function for XSetErrorHandler
+(XErrorHandler)XSetErrorHandler:(XErrorHandler)handler
{
    static XSetErrorHandlerFunction *func = NULL;
	XErrorHandler errorHandlerReturn;
    
    if (!xlibRef)
		xlibRef = dlopen(xlib_path, RTLD_GLOBAL | RTLD_LAZY);
	
    if (!func) {
		func = (XSetErrorHandlerFunction *) dlsym(xlibRef, "XSetErrorHandler");
	}
    
    @try
    {
        if (xlibRef && func)
        {
            errorHandlerReturn = func(handler);
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"XSetErrorHandlerException"
                                                             reason:@"Could not execute Xlib function."
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception)
    {
        @throw;
    }
    
    return errorHandlerReturn;
}

// type define for the XMoveWindow function we'll be calling
typedef int(XMoveWindowFunction) (Display *_display, Window _w, int _x, int _y);

// wrapper function for XMoveWindow
+(int)XMoveWindow:(Display *)display window:(Window) w x:(int) x y:(int)y
{
    static XMoveWindowFunction *func = NULL;
	int moveReturn;
    
    if (!xlibRef)
		xlibRef = dlopen(xlib_path, RTLD_GLOBAL | RTLD_LAZY);
	
    if (!func) {
		func = (XMoveWindowFunction *) dlsym(xlibRef, "XMoveWindow");
	}
    
    @try
    {
        if (xlibRef && func)
        {
            moveReturn = func(display, w, x, y);
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"XMoveWindowException"
                                                             reason:@"Could not execute Xlib function."
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception)
    {
        @throw;
    }
    
    
    return moveReturn;
}

// type define for the XSync function we'll be calling
typedef int(XSyncFunction) (Display *_display, Bool _discard);

// wrapper function for XSync
+(int) XSync:(Display *)display discard:(Bool)discard
{
    static XSyncFunction *func = NULL;
	int syncReturn;
    
    if (!xlibRef)
		xlibRef = dlopen(xlib_path, RTLD_GLOBAL | RTLD_LAZY);
	
    if (!func) {
		func = (XSyncFunction *) dlsym(xlibRef, "XSync");
	}
    
    @try
    {
        if (xlibRef && func)
        {
            syncReturn = func(display, discard);
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"XSyncException"
                                                             reason:@"Could not execute Xlib function."
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception)
    {
        @throw;
    }
    
    return syncReturn;
}

// type define for the XGetNormalHints function we'll be calling
typedef Status(XGetNormalHintsFunction) (Display *_display, Window _w, XSizeHints *_hints_return);

// wrapper function for XGetNormalHints
+(Status)XGetNormalHints:(Display *)display window:(Window) w hints:(XSizeHints *)hints_return
{
    static XGetNormalHintsFunction *func = NULL;
	Status hintsReturn;
    
    if (!xlibRef)
		xlibRef = dlopen(xlib_path, RTLD_GLOBAL | RTLD_LAZY);
	
    if (!func) {
		func = (XGetNormalHintsFunction *) dlsym(xlibRef, "XGetNormalHints");
	}
    
    @try
    {
        if (xlibRef && func)
        {
            hintsReturn = func(display, w, hints_return);
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"XGetNormalHintsException"
                                                             reason:@"Could not execute Xlib function."
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception)
    {
        @throw;
    }
    
    return hintsReturn;
}

// type define for the XGetNormalHints function we'll be calling
typedef Status(XGetWindowAttributesFunction) (Display *_display, Window _w, XWindowAttributes *_window_attributes_return);

// wrapper function for XGetNormalHints
+(Status) XGetWindowAttributes:(Display *)display window:(Window)w attributes:(XWindowAttributes *)window_attributes_return
{
    static XGetWindowAttributesFunction *func = NULL;
	Status attrReturn;
    
    if (!xlibRef)
		xlibRef = dlopen(xlib_path, RTLD_GLOBAL | RTLD_LAZY);
	
    if (!func) {
		func = (XGetWindowAttributesFunction *) dlsym(xlibRef, "XGetWindowAttributes");
	}
    
    @try
    {
        if (xlibRef && func)
        {
            attrReturn = func(display, w, window_attributes_return);
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"XGetWindowAttributesException"
                                                             reason:@"Could not execute Xlib function."
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception)
    {
        @throw;
    }
    
    return attrReturn;
}

// type define for the XResizeWindow function we'll be calling
typedef int(XResizeWindowFunction) (Display *_display, Window _w, unsigned int _width, unsigned int _height);

// wrapper function for XResizeWindow
+(int)XResizeWindow:(Display *)display window:(Window)w width:(unsigned int)width height:(unsigned int)height
{
    static XResizeWindowFunction *func = NULL;
	int resizeReturn;
    
    if (!xlibRef)
		xlibRef = dlopen(xlib_path, RTLD_GLOBAL | RTLD_LAZY);
	
    if (!func) {
		func = (XResizeWindowFunction *) dlsym(xlibRef, "XResizeWindow");
	}
    
    @try
    {
        if (xlibRef && func)
        {
            resizeReturn = func(display, w, width, height);
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"XResizeWindowException"
                                                             reason:@"Could not execute Xlib function."
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception)
    {
        @throw;
    }
    
    return resizeReturn;
}

// type define for the XGetWindowProperty function we'll be calling
typedef int(XGetWindowPropertyFunction) (Display *_display, Window _w, Atom _property, long _long_offset, long _long_length, Bool _delete, Atom _req_type, Atom *_actual_type_return,
int *_actual_format_return, unsigned long *_nitems_return, unsigned long *_bytes_after_return, unsigned char **_prop_return);

// wrapper function for XGetWindowProperty
+(int)XGetWindowProperty:(Display *)display window:(Window)w property:(Atom)property offset:(long)long_offset length:(long)long_length delete:(Bool)delete reqType:(Atom)req_type actual:(Atom *)actual_type_return
            actualFormat:(int *)actual_format_return nitems:(unsigned long *)nitems_return bytes:(unsigned long *)bytes_after_return prop:(unsigned char **)prop_return
{
    static XGetWindowPropertyFunction *func = NULL;
	int propReturn;
    
    if (!xlibRef)
		xlibRef = dlopen(xlib_path, RTLD_GLOBAL | RTLD_LAZY);
	
    if (!func) {
		func = (XGetWindowPropertyFunction *) dlsym(xlibRef, "XGetWindowProperty");
	}
    
    @try
    {
        if (xlibRef && func)
        {
            propReturn = func(display, w, property, long_offset, long_length, delete, req_type, actual_type_return,
                              actual_format_return, nitems_return, bytes_after_return, prop_return);
            
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"XGetWindowPropertyException"
                                                             reason:@"Could not execute Xlib function."
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception)
    {
        @throw;
    }
    
    return propReturn;
}

// type define for the XTranslateCoordinates function we'll be calling
typedef Bool(XTranslateCoordinatesFunction) (Display *_display, Window _src_w, Window _dest_w, int _src_x, int _src_y, int *_dest_x_return, int *_dest_y_return, Window *_child_return);

// wrapper function for XTranslateCoordinates
+(Bool)XTranslateCoordinates:(Display *)display srcWindow:(Window)src_w destWindow:(Window)dest_w srcX:(int)src_x srcY:(int)src_y dextX:(int *)dest_x_return destY:(int *)dest_y_return child:(Window *)child_return
{
    static XTranslateCoordinatesFunction *func = NULL;
	int translateReturn;
    
    if (!xlibRef)
		xlibRef = dlopen(xlib_path, RTLD_GLOBAL | RTLD_LAZY);
	
    if (!func) {
		func = (XTranslateCoordinatesFunction *) dlsym(xlibRef, "XTranslateCoordinates");
	}
    
    @try
    {
        if (xlibRef && func)
        {
            translateReturn = func(display, src_w, dest_w, src_x, src_y, dest_x_return, dest_y_return, child_return);
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"XTranslateCoordinatesException"
                                                             reason:@"Could not execute Xlib function."
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception)
    {
        @throw;
    }
    
    return translateReturn;
}

// type define for the XFree function we'll be calling
typedef int(XFreeFunction) (void *_data);

// wrapper function for XFree
+(int)XFree:(void *)data
{
    static XFreeFunction *func = NULL;
	int freeReturn;
    
    if (!xlibRef)
		xlibRef = dlopen(xlib_path, RTLD_GLOBAL | RTLD_LAZY);
	
    if (!func) {
		func = (XFreeFunction *) dlsym(xlibRef, "XFree");
	}
    
    @try
    {
        if (xlibRef && func)
        {
            freeReturn = func(data);
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"XFreeException"
                                                             reason:@"Could not execute Xlib function."
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception)
    {
        @throw;
    }
    
    return freeReturn;
}

// type define for the XInternAtom function we'll be calling
typedef Atom(XInternAtomFunction) (Display *_display, _Xconst char *_atom_name, Bool _only_if_exists);

// wrapper function for XInternAtom
+(Atom) XInternAtom:(Display *)display atomName:(_Xconst char *)atom_name onlyIfExists:(Bool)only_if_exists
{
    static XInternAtomFunction *func = NULL;
	Atom atomReturn;
    
    if (!xlibRef)
		xlibRef = dlopen(xlib_path, RTLD_GLOBAL | RTLD_LAZY);
	
    if (!func) {
		func = (XInternAtomFunction *) dlsym(xlibRef, "XInternAtom");
	}
    
    @try
    {
        if (xlibRef && func)
        {
            atomReturn = func(display, atom_name, only_if_exists);
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"XInternAtomException"
                                                             reason:@"Could not execute Xlib function."
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception)
    {
        @throw;
    }
    
    return atomReturn;
}

@end
