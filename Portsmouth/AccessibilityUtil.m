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
//  AccessibilityUtil.m
//  Portsmouth


#import "AccessibilityUtil.h"

@implementation AccessibilityUtil

+(NSString *)getApplicationName:(AXUIElementRef)element
{
    AXUIElementRef applicationNameRef;
    NSString *applicationName;
    NSString *roleName;
    
    CFTypeRef roleNameRef = NULL;
    
    if (AXUIElementCopyAttributeValue((AXUIElementRef)element, kAXRoleAttribute, (CFTypeRef *)&roleNameRef) == kAXErrorSuccess) {
        
        roleName = [(__bridge id)roleNameRef description];
        
        if (roleNameRef)
        {
            CFRelease(roleNameRef);
            roleNameRef = nil;
        }
        
        if (roleName && ![roleName isEqualToString:@"AXApplication"])
        {
            AXUIElementRef parent;
            
            if (AXUIElementCopyAttributeValue(element, (CFStringRef)NSAccessibilityParentAttribute, (CFTypeRef *)&parent) == kAXErrorSuccess)
            {
                applicationName = [AccessibilityUtil getApplicationName:parent];
                
                if (parent)
                {
                    log4Debug(@"Freeing parent");
                    CFRelease(parent);
                    parent = nil;
                }
            }
        }
        else
        {
            if (AXUIElementCopyAttributeValue((AXUIElementRef)element, (CFStringRef)NSAccessibilityTitleAttribute, (CFTypeRef *)&applicationNameRef) == kAXErrorSuccess)
            {
                applicationName = [(__bridge id)applicationNameRef description];
                if (applicationNameRef)
                {
                    CFRelease(applicationNameRef);
                    applicationNameRef = nil;
                }
            }
        }
        
    }
    
    return applicationName;
}

+(NSString *)firstDescriptionInElementHierarchy:(AXUIElementRef)element
{
    AXUIElementRef descriptionNameRef;
    NSString *descriptionName;
    NSString *roleName;
    
    CFTypeRef roleNameRef = NULL;
    
    if (AXUIElementCopyAttributeValue((AXUIElementRef)element, kAXRoleAttribute, (CFTypeRef *)&roleNameRef) == kAXErrorSuccess) {
        
        roleName = [(__bridge id)roleNameRef description];
        
        if (roleNameRef)
        {
            CFRelease(roleNameRef);
            roleNameRef = nil;
        }
        
        if (roleName && ![roleName isEqualToString:@"AXScrollArea"])
        {
            AXUIElementRef parent;
            
            if (AXUIElementCopyAttributeValue(element, (CFStringRef)NSAccessibilityParentAttribute, (CFTypeRef *)&parent) == kAXErrorSuccess)
            {
                descriptionName = [AccessibilityUtil firstDescriptionInElementHierarchy:parent];
                
                if (parent)
                {
                    log4Debug(@"Freeing parent");
                    CFRelease(parent);
                    parent = nil;
                }
            }
        }
        else
        {
            if (AXUIElementCopyAttributeValue((AXUIElementRef)element, (CFStringRef)NSAccessibilityDescriptionAttribute, (CFTypeRef *)&descriptionNameRef) == kAXErrorSuccess)
            {
                descriptionName = [(__bridge id)descriptionNameRef description];
                if (descriptionNameRef)
                {
                    CFRelease(descriptionNameRef);
                    descriptionNameRef = nil;
                }
            }
        }
        
    }
    
    return descriptionName;
}


+(Boolean)isDesktopWindow:(AXUIElementRef)window
{
    NSString *application;
    NSString *description;
    CFTypeRef focusedUIElement = NULL;
    
    @try
    {
        
        
        application = [AccessibilityUtil getApplicationName:window];
        
        log4Debug(@"applicationName: %@", application);
        
        if (application && [application isEqualToString:@"Finder"])
        {
            // if it's the desktop...
            if (AXUIElementCopyAttributeValue((AXUIElementRef)window,(CFStringRef)NSAccessibilityFocusedUIElementAttribute,(CFTypeRef*)&focusedUIElement) != kAXErrorSuccess)
            {
                NSException *exception = [NSException exceptionWithName:@"IsDesktopWindow"
                                                                 reason:@"Unable to determine focused component"
                                                               userInfo:nil];
                @throw exception;
            }
            else
            {
                description = [AccessibilityUtil firstDescriptionInElementHierarchy:focusedUIElement];
            }
            
        }
            
    }
    @catch (NSException *exception) {
        @throw;
    }
    @finally {
        if (focusedUIElement)
        {
            log4Debug(@"Freeing focuseUIElement");
            CFRelease(focusedUIElement);
        }
    }
    
    
    if (description)
    {
        return [description isEqualToString:@"desktop"];
    }
    else
    {
        return NO;
    }
}


+(void)setWindowPosition:(AXUIElementRef)window x: (int) x y: (int) y 
{
    
    NSPoint position = {x, y};
    CFTypeRef positionRef = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&position));
    
    @try 
    {
        if(AXUIElementSetAttributeValue((AXUIElementRef)window,(CFStringRef)NSAccessibilityPositionAttribute,(CFTypeRef*)positionRef) != kAXErrorSuccess)
        {
            NSException *exception = [NSException exceptionWithName:@"SetWindowPositionFailedException" 
                                                             reason:@"The accessibility reposition failed"
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception) 
    {
        @throw;
    }
    @finally 
    {
        CFRelease(positionRef);
    }
}

+(void)setWindowSize:(AXUIElementRef)window width: (unsigned int) width height: (unsigned int) height 
{
    
    NSSize size = {width, height};
	CFTypeRef sizeRef = (CFTypeRef)(AXValueCreate(kAXValueCGSizeType, (const void *)&size));
    
    @try 
    {
        if(AXUIElementSetAttributeValue((AXUIElementRef)window,(CFStringRef)NSAccessibilitySizeAttribute,(CFTypeRef*)sizeRef) != kAXErrorSuccess)
        {
            NSException *exception = [NSException exceptionWithName:@"SetWindowSizeFailedException" 
                                                             reason:@"The accessibility reposition failed"
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception) 
    {
        @throw;
    }
    @finally 
    {
        CFRelease(sizeRef);
    }
}

+(Boolean)canSetFullscreen:(AXUIElementRef)window
{
    Boolean isFullscreenable;
    
   
    AXUIElementIsAttributeSettable(window, (CFStringRef)@"AXFullScreen", &isFullscreenable);
   
    
    return isFullscreenable;
}

+(Boolean) isCurrentlyFullscreened:(AXUIElementRef) window
{
	CFTypeRef fullscreenRef;
	NSString *string;
    
    @try
    {
        
        // copy the accessibility position reference
        if (AXUIElementCopyAttributeValue((AXUIElementRef)window,(CFStringRef)@"AXFullScreen",(CFTypeRef*)&fullscreenRef) != kAXErrorSuccess)
        {
            NSException *exception = [NSException exceptionWithName:@"IsCurrentlyFullscreened"
                                                             reason:@"Unable to determine if the window is fullscreened"
                                                           userInfo:nil];
            @throw exception;
        }
        
        string = [(__bridge id)fullscreenRef description];
        
        
    }
    @catch (NSException *exception) {
        @throw;
    }
    @finally {
        if (fullscreenRef)
        {
            CFRelease(fullscreenRef);
        }
    }
    
    
    if (string)
    {
        return [string isEqualToString:@"1"];
    }
    else
    {
        return NO;
    }
}

+(void)setFullscreen:(AXUIElementRef)window
{
    @try {
        if ([AccessibilityUtil canSetFullscreen:window])
        {
            AXUIElementSetAttributeValue( window, (CFStringRef)@"AXFullScreen", (__bridge CFTypeRef)([NSNumber numberWithFloat:(float)1]));
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"SetFullscreen"
                                                             reason:@"The OSX Lion Fullscreen functionality is not availabile"
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception)
    {
        @throw;
    }
}

+(void)removeFullscreen:(AXUIElementRef)window
{
    @try {
        if ([AccessibilityUtil canSetFullscreen:window])
        {
            AXUIElementSetAttributeValue( window, (CFStringRef)@"AXFullScreen", (__bridge CFTypeRef)([NSNumber numberWithFloat:(float)0]));
        }
        else
        {
            NSException *exception = [NSException exceptionWithName:@"RemoveFullscreen"
                                                             reason:@"The OSX Lion Fullscreen functionality is not availabile"
                                                           userInfo:nil];
            @throw exception;
        }
    }
    @catch (NSException *exception)
    {
        @throw;
    }
}

+(AXUIElementRef)getActiveWindow
{
	AXUIElementRef systemElementRef = AXUIElementCreateSystemWide();
	AXUIElementRef focusedAppRef = nil;
	AXUIElementRef focusedWindowRef = nil;
	
	@try 
    {
        //get the focused application
        if (AXUIElementCopyAttributeValue(systemElementRef, (CFStringRef) kAXFocusedApplicationAttribute, (CFTypeRef *) &focusedAppRef) != kAXErrorSuccess) 
        {
            NSException *exception = [NSException exceptionWithName:@"GetActiveWindowFailedException" 
                                                             reason:@"Unable to get the focused application"
                                                           userInfo:nil];
            @throw exception;
        }
        
        //get the focused window
        if (AXUIElementCopyAttributeValue((AXUIElementRef)focusedAppRef, (CFStringRef)NSAccessibilityFocusedWindowAttribute, (CFTypeRef*)&focusedWindowRef) != kAXErrorSuccess) 
        {
            NSException *exception = [NSException exceptionWithName:@"GetActiveWindowFailedException" 
                                                             reason:@"Unable to get the focused window"
                                                           userInfo:nil];
            @throw exception;
        }
        
        // We don't want the desktop window in this application
        if ([AccessibilityUtil isDesktopWindow:focusedAppRef])
        {
            if (focusedAppRef != nil) {
                log4Debug(@"getActiveWindow: releasing focusedAppRef isDesktopWindow");
                CFRelease(focusedAppRef);
                focusedAppRef = nil;
            }
            
            if (focusedWindowRef != nil) {
                log4Debug(@"getActiveWindow: releasing focusedWindowRef isDesktopWindow");
                CFRelease(focusedWindowRef);
                focusedWindowRef = nil;
            }
            
            return NULL;
        }
        
        
    }
    @catch (NSException *exception) 
    {
        // if we failed to get the focused window but we got the focused app,
        if (focusedAppRef != nil)
        {
            // try to get the main window (for cases like the twitter application for osx).
            if (AXUIElementCopyAttributeValue((AXUIElementRef)focusedAppRef, (CFStringRef)kAXMainWindowAttribute, (CFTypeRef*)&focusedWindowRef) != kAXErrorSuccess) 
            {
                @throw;
            }
        }
    }
    @finally 
    {
        log4Debug(@"getActiveWindow: releasing systemElementRef");
        CFRelease(systemElementRef);
        
        if (focusedAppRef != nil) {
            log4Debug(@"getActiveWindow: releasing focusedAppRef");
            CFRelease(focusedAppRef);
        }
        
    }
    
    return focusedWindowRef;
}


+(BOOL) isWindowResizable:(AXUIElementRef) window
{
    Boolean isSettable = false;
    
    AXUIElementIsAttributeSettable(window, (CFStringRef)NSAccessibilitySizeAttribute, &isSettable);
    
    return isSettable;
}

+ (NSPoint) getWindowPosition:(AXUIElementRef)window
{
    NSPoint point;
    CFTypeRef value = NULL;
    if (AXUIElementCopyAttributeValue(window,kAXPositionAttribute,
                                      &value) != kAXErrorSuccess)
    {
        NSException *exception = [NSException exceptionWithName:@"GetWindowPositionException"
                                                         reason:@"Unable to copy accessibility position attribute"
                                                       userInfo:nil];
        @throw exception;
    }
    
    if (!AXValueGetValue(value,AXValueGetType(value),&point))
    {
        NSException *exception = [NSException exceptionWithName:@"GetWindowPositionException"
                                                         reason:@"Unable to get position"
                                                       userInfo:nil];
        @throw exception;
    }
    //CFRelease(value);
    
    
    return point;
}

+ (NSSize) getWindowSize:(AXUIElementRef)window
{
    NSSize size;
    CFTypeRef value = NULL;
    if (AXUIElementCopyAttributeValue(window,kAXSizeAttribute,
                                      &value) != kAXErrorSuccess)
    {
        NSException *exception = [NSException exceptionWithName:@"GetWindowSizeException"
                                                         reason:@"Unable to copy accessibility size attribute"
                                                       userInfo:nil];
        @throw exception;
    }
    
    if (!AXValueGetValue(value,AXValueGetType(value),&size))
    {
        NSException *exception = [NSException exceptionWithName:@"GetWindowSizeException"
                                                           reason:@"Unable to get size"
                                                         userInfo:nil];
         @throw exception;
    }
    //CFRelease(value);
    
    return size;
}

+(NSRect) getWindowGeometry:(AXUIElementRef) window
{
	NSRect geometry;
	
    geometry.origin = [AccessibilityUtil getWindowPosition:window];
    geometry.size = [AccessibilityUtil getWindowSize:window];
    
    
    return geometry;
}

+(void) freeRef:(AXUIElementRef)ref
{
    if (ref)
    {
        log4Debug(@"freeWindowRef: releasing window");
        CFRelease((CFTypeRef) ref);
    }
}

@end
