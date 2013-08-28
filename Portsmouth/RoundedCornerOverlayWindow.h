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
//  RoundedCornerOverlayWindow.h
//  Portsmouth


#import <Cocoa/Cocoa.h>
#import "BorderStyle.h"

@interface RoundedCornerOverlayWindow : NSWindow
{
    NSColor *_borderColor;
    NSColor *_overlayBackgroundColor;
    float _borderWidth;
    float _viewMargin;
    float _cornerRadius;
    NSRect _contentRect;
    enum BorderStyle _borderStyle; 
}

-(id)initWithContentRect:(NSRect)contentRect backgroundColor:(NSColor*) backgroundColor borderColor:(NSColor*)borderColor borderWidth:(float)borderWidth borderStyle:(enum BorderStyle)borderStyle cornerRadius:(float)cornerRadius ignoresInteraction:(Boolean)ignoresInteraction;

- (BOOL) canBecomeKeyWindow;

@end
