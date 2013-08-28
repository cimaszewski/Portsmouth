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
//  X11WeakLinker.h
//  Portsmouth


#import <Foundation/Foundation.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/Xutil.h>

@interface X11WeakLinker : NSObject

// wrapper function for XGetErrorText
+(int) XGetErrorText:(Display *) display code:(int)code bufferRetuern:(char *)buffer_return length:(int)length;

// wrapper function for XOpenDisplay
+(Display*) XOpenDisplay:(_Xconst char *)display_name;

// wrapper function for XCloseDisplay
+(int)XCloseDisplay:(Display *)display;

// wrapper function for XSetErrorHandler
+(XErrorHandler)XSetErrorHandler:(XErrorHandler)handler;

// wrapper function for XMoveWindow
+(int)XMoveWindow:(Display *)display window:(Window) w x:(int) x y:(int)y;

// wrapper function for XSync
+(int) XSync:(Display *)display discard:(Bool)discard;

// wrapper function for XGetNormalHints
+(Status)XGetNormalHints:(Display *)display window:(Window) w hints:(XSizeHints *)hints_return;

// wrapper function for XGetNormalHints
+(Status) XGetWindowAttributes:(Display *)display window:(Window)w attributes:(XWindowAttributes *)window_attributes_return;

// wrapper function for XResizeWindow
+(int)XResizeWindow:(Display *)display window:(Window)w width:(unsigned int)width height:(unsigned int)height;

// wrapper function for XGetWindowProperty
+(int)XGetWindowProperty:(Display *)display window:(Window)w property:(Atom)property offset:(long)long_offset length:(long)long_length delete:(Bool)delete reqType:(Atom)req_type actual:(Atom *)actual_type_return
actualFormat:(int *)actual_format_return nitems:(unsigned long *)nitems_return bytes:(unsigned long *)bytes_after_return prop:(unsigned char **)prop_return;

// wrapper function for XTranslateCoordinates
+(Bool)XTranslateCoordinates:(Display *)display srcWindow:(Window)src_w destWindow:(Window)dest_w srcX:(int)src_x srcY:(int)src_y dextX:(int *)dest_x_return destY:(int *)dest_y_return child:(Window *)child_return;

// wrapper function for XFree
+(int)XFree:(void *)data;

// wrapper function for XInternAtom
+(Atom) XInternAtom:(Display *)display atomName:(_Xconst char *)atom_name onlyIfExists:(Bool)only_if_exists;

@end
