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
//  WindowMoverView.h
//  Portsmouth


#import <Cocoa/Cocoa.h>
#import "WindowMoverDelegate.h"

@interface WindowMoverView : NSMatrix
{
    
    NSImage *_imageUp;
    NSImage *_imageRight;
    NSImage *_imageDown;
    NSImage *_imageLeft;
    
    NSImage *_imageUpLeft;
    NSImage *_imageUpRight;
    NSImage *_imageDownRight;
    NSImage *_imageDownLeft;
    
    NSImage *_imageCenter;
    NSImage *_imageCenterAlt;
    id <WindowMoverDelegate> _windowMover;
}

@property id <WindowMoverDelegate> windowMover;

- (id)initWithFrame:(NSRect)frame;

-(void)toggleAltImages:(Boolean)altImageFlag;


@end
