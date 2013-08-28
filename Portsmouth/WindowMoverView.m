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
//  WindowMoverView.m
//  Portsmouth


#import "WindowMoverView.h"
#import "WindowMoverCell.h"

@implementation WindowMoverView
@synthesize windowMover = _windowMover;


- (id)initWithFrame:(NSRect)frame
{
    
    WindowMoverCell *prototype = [[WindowMoverCell alloc] init];
    [prototype setEnabled:YES];
    
    
    self = [super initWithFrame:frame mode:NSHighlightModeMatrix prototype:prototype numberOfRows:3 numberOfColumns:3];
    if (self) {
        
        [self setCellSize:NSMakeSize(72, 72)];
        [self setIntercellSpacing:NSMakeSize(16,16)];
        
        
        
        NSArray *cellArray = [self cells];
        
        _imageUp = [NSImage imageNamed:@"edgeArrow.tiff"];
        _imageRight = [self rotateIndividualImage:_imageUp clockwise:YES];
        _imageDown = [self rotateIndividualImage:_imageRight clockwise:YES];
        _imageLeft = [self rotateIndividualImage:_imageDown clockwise:YES];
        
        
        _imageUpLeft = [NSImage imageNamed:@"cornerArrow.tiff"];
        _imageUpRight = [self rotateIndividualImage:_imageUpLeft clockwise:YES];
        _imageDownRight = [self rotateIndividualImage:_imageUpRight clockwise:YES];
        _imageDownLeft = [self rotateIndividualImage:_imageDownRight clockwise:YES];
        
        _imageCenter = [NSImage imageNamed:@"center.tiff"];
        _imageCenterAlt = [NSImage imageNamed:@"center_alt.tiff"];
        
        [[cellArray objectAtIndex:0] setImage:_imageUpLeft];
        [[cellArray objectAtIndex:1] setImage:_imageUp];
        [[cellArray objectAtIndex:2] setImage:_imageUpRight];
        [[cellArray objectAtIndex:3] setImage:_imageLeft];
        [[cellArray objectAtIndex:4] setImage:_imageCenter];
        [[cellArray objectAtIndex:5] setImage:_imageRight];
        [[cellArray objectAtIndex:6] setImage:_imageDownLeft];
        [[cellArray objectAtIndex:7] setImage:_imageDown];
        [[cellArray objectAtIndex:8] setImage:_imageDownRight];
        
        
        int opts = (NSTrackingMouseMoved | NSTrackingActiveAlways);
        [self addTrackingArea:[ [NSTrackingArea alloc] initWithRect:[self frame]
                                                             options:opts
                                                               owner:self
                                                            userInfo:nil]];
    
        
    }
    
    return self;
}

- (NSImage *)rotateIndividualImage: (NSImage *)image clockwise: (BOOL)clockwise
{
    NSImage *existingImage = image;
    
    
    NSSize newSize = NSMakeSize(existingImage.size.height, existingImage.size.width);
    NSImage *rotatedImage = [[NSImage alloc] initWithSize:newSize];
    
    [rotatedImage lockFocus];
    
    
    NSAffineTransform *rotateTF = [NSAffineTransform transform];
    NSPoint centerPoint = NSMakePoint(newSize.width / 2, newSize.height / 2);
    
    [rotateTF translateXBy: centerPoint.x yBy: centerPoint.y];
    [rotateTF rotateByDegrees: (clockwise) ? - 90 : 90];
    [rotateTF translateXBy: -centerPoint.y yBy: -centerPoint.x];
    [rotateTF concat];
    
   
    NSRect r1 = NSMakeRect(0, 0, newSize.height, newSize.width);
    [existingImage drawInRect:r1 fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
    [rotatedImage unlockFocus];
    
    
    
    return rotatedImage;
}



-(void)toggleAltImages:(Boolean)altImageFlag
{
    if (altImageFlag)
    {
        [[[self cells] objectAtIndex:4] setImage:_imageCenterAlt];
    }
    else
    {
        [[[self cells] objectAtIndex:4] setImage:_imageCenter];
    }
    [[self window] invalidateShadow];
}




@end
