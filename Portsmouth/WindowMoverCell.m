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
//  WindowMoverCell.m
//  Portsmouth


#import "WindowMoverCell.h"
#import "WindowMoverView.h"

 
@implementation WindowMoverCell

@synthesize overlayTarget = _overlayTarget;

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    if ([self isHighlighted] || [self state] == NSOnState) {
        
        CGFloat scaleFactor = 1.f;
        if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)]) {
            scaleFactor = [NSScreen mainScreen].backingScaleFactor;
        }
        
        NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
        
        CGFloat roundedRadius = 8.0f;
        
        [ctx saveGraphicsState];
        [[NSColor colorWithDeviceWhite:1.0f alpha:1.0f] setStroke];
        [[NSColor colorWithDeviceWhite:0.0f alpha:.3f] setFill];
        
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 4.0f, 4.0f)
                                                             xRadius:roundedRadius
                                                             yRadius:roundedRadius];
        
        // Double the borderWidth since we're drawing inside the path.
        [path setLineWidth:(1.5) * scaleFactor];
        [path fill];
        [path stroke];
        [ctx restoreGraphicsState];
    }
    
    // calculate the rect
    NSRect rect = NSZeroRect;
    rect.size = [self.image size];
    rect.origin = frame.origin;
    
    // always center
    rect.origin.x += (NSWidth(frame) - rect.size.width) / 2;
    rect.origin.y += (NSHeight(frame) - rect.size.height) / 2;
   
    NSCompositingOperation op = ([self isHighlighted]) ? NSCompositeHighlight : NSCompositeSourceOver;
    
    [self.image drawInRect:rect fromRect:NSZeroRect operation:op fraction:1.0 respectFlipped:YES hints:nil];
    
    [[controlView window] invalidateShadow];
}

- (void)_sendActionFrom:(id)sender
{
    [[NSApplication sharedApplication] sendAction:[self action] to:[self
                                                                    target] from:self];
    
    [self setHighlighted:NO];
}


-(BOOL) trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag
{
    [(WindowMoverView *)controlView deselectAllCells];
    
    if ([((WindowMoverView *)controlView) windowMover])
    {
        [[((WindowMoverView *)controlView) windowMover] clickEventDetectedForTarget:_overlayTarget];
    }
    
    //[((WindowMoverView *)controlView).controller clickEventDetectedForTarget:_overlayTarget];
    
    
    return YES;
}



@end
