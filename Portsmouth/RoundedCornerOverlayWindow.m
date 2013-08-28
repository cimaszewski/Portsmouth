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
//  RoundedCornerOverlayWindow.m
//  Portsmouth

#import "RoundedCornerOverlayWindow.h"

@implementation RoundedCornerOverlayWindow

- (NSBezierPath *)createBackgroundPath
{    
    float scaleFactor = [self backingScaleFactor];
    
    // fix the retina issue?  Without the initializaton of this object, the scaling doesn't work
    // it only needs to be initialized if it's not 1
    if (scaleFactor != 1.0f)
    {
        NSAffineTransform *trans = [[NSAffineTransform alloc] init];
        [trans set];
    }
    
    float scaledRadius = _cornerRadius * scaleFactor;
    
    float minX = ceilf(NSMinX(_contentRect) * scaleFactor + 0.5f);
	float maxX = floorf(NSMaxX(_contentRect) * scaleFactor - 0.5f);
	float minY = ceilf(NSMinY(_contentRect) * scaleFactor + 0.5f);
	float maxY = floorf(NSMaxY(_contentRect) * scaleFactor - 0.5f);
    
	
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineJoinStyle:NSRoundLineJoinStyle];
    
    // Start at the top left of the window
    NSPoint currentPoint = NSMakePoint(minX, maxY);
    
    currentPoint.x += scaledRadius;
    
    // Point at top right
    NSPoint endPoint = NSMakePoint(maxX, maxY);
    endPoint.x -= scaledRadius;
    
    [path moveToPoint:currentPoint];
    
    // Line to end point at top right
    [path lineToPoint:endPoint];
    
    // Rounded corner on top right
    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                   toPoint:NSMakePoint(maxX, maxY - scaledRadius) 
                                    radius:scaledRadius];
    
    
    // Point at bottom right
    endPoint = NSMakePoint(maxX, minY);
    endPoint.y += scaledRadius;
    
    
    // Line to end point at bottom right
    [path lineToPoint:endPoint];
    
    // Rounded corner on bottom right
    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                   toPoint:NSMakePoint(maxX - scaledRadius, minY) 
                                    radius:scaledRadius];
    
    // Point at bottom left
    endPoint = NSMakePoint(minX, minY);
    endPoint.x += scaledRadius;
    
    // Line to end point at the bottom left
    [path lineToPoint:endPoint];
    
    // Rounded corner on bottom left
    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX, minY) 
                                   toPoint:NSMakePoint(minX, minY + scaledRadius) 
                                    radius:scaledRadius];
    
    // Point at top left
    endPoint = NSMakePoint(minX, maxY);
    endPoint.y -= scaledRadius;
    
    // Line to end point at the top left
    [path lineToPoint:endPoint];
    
    // Rounded corner on top left
    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                   toPoint:NSMakePoint(minX + scaledRadius, maxY) 
                                    radius:scaledRadius];
    
    // end the path
    [path closePath];
    
    // return the path
    return path;
}

- (NSColor *)createBackgroundPatternImage
{
    NSImage *background = [[NSImage alloc] initWithSize:_contentRect.size];
    
    [background lockFocus];
    
    NSBezierPath *path = [self createBackgroundPath];
    [NSGraphicsContext saveGraphicsState];
    [path addClip];
    
    // Draw background
    [_overlayBackgroundColor set];
    [path fill];
    
    // Draw border
    if (_borderWidth > 0 && _borderStyle != noborder)
    {
        CGFloat dash[4];
        
        switch (_borderStyle) 
        {
            case shortDash:
                dash[0] = 4.0 * [self backingScaleFactor];
                dash[1] = 4.0 * [self backingScaleFactor];
                [path setLineDash:dash count:2 phase:0];
                break;
            case longDash:
                dash[0] = 15.0 * [self backingScaleFactor];
                dash[1] = 4.0 * [self backingScaleFactor];
                [path setLineDash:dash count:2 phase:0];
                break;
            case alternatingDash:
                dash[0] = 15.0 * [self backingScaleFactor];
                dash[1] = 4.0 * [self backingScaleFactor];
                dash[2] = 4.0 * [self backingScaleFactor];
                dash[3] = 4.0 * [self backingScaleFactor];
                [path setLineDash:dash count:4 phase:0];
                break;
            case solid:
            case noborder:
            default:
                break;
        }
        
        // Double the borderWidth since we're drawing inside the path.
        [path setLineWidth:(_borderWidth * 2.0) * [self backingScaleFactor]];
        [_borderColor set];
        
        [path stroke];
    }
    
    [NSGraphicsContext restoreGraphicsState];
    [background unlockFocus];
    
    return [NSColor colorWithPatternImage:background];
}

-(void)setFrame:(NSRect)frameRect display:(BOOL)flag
{
    _contentRect = frameRect;
    
    _contentRect.origin.x = 0;
    _contentRect.origin.y = 0;
    
    if (!NSEqualRects(frameRect, NSZeroRect))
    {
        NSDisableScreenUpdates();
        [super setFrame:frameRect display:flag];
        [super setBackgroundColor:[self createBackgroundPatternImage]];
        if ([self isVisible]) {
            [self display];
            [self invalidateShadow];
        }
        NSEnableScreenUpdates();
    }
}

-(void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animateFlag
{
    _contentRect = frameRect;
    
    _contentRect.origin.x = 0;
    _contentRect.origin.y = 0;
    
    if (!NSEqualRects(frameRect, NSZeroRect))
    {
        NSDisableScreenUpdates();
        [super setFrame:frameRect display:displayFlag animate:animateFlag];
        [super setBackgroundColor:[self createBackgroundPatternImage]];
        if ([self isVisible]) {
            [self display];
            [self invalidateShadow];
        }
        NSEnableScreenUpdates();
        [self display];
    }
}

-(id)initWithContentRect:(NSRect)contentRect backgroundColor:(NSColor*) backgroundColor borderColor:(NSColor*)borderColor borderWidth:(float)borderWidth borderStyle:(enum BorderStyle)borderStyle cornerRadius:(float)cornerRadius ignoresInteraction:(Boolean)ignoresInteraction
{
    if ((self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO])) 
    {
        [self setOpaque:NO];
        [self setHasShadow:YES];
        if (ignoresInteraction)
        {
            [self setLevel:NSFloatingWindowLevel];
        }
        else
        {
            [self setLevel:kCGMaximumWindowLevel];
        }
        [self orderOut:nil];
        [self display];
        
        // This next line sets things so that we can click through the blue selection box to
        // click buttons in the matrix underneath.
        [self setIgnoresMouseEvents:ignoresInteraction];
        
        
        _overlayBackgroundColor = backgroundColor;
        _borderColor = borderColor;
        _borderWidth = borderWidth;
        _cornerRadius = cornerRadius;
        _contentRect = contentRect;
        _borderStyle = borderStyle;
        
        _contentRect.origin.x = 0;
        _contentRect.origin.y = 0;
        
        NSDisableScreenUpdates();
        [super setBackgroundColor:[self createBackgroundPatternImage]];
        if ([self isVisible]) {
            [self display];
            [self invalidateShadow];
        }
        NSEnableScreenUpdates();
        
        // Move the trackingWin to the front
        [self orderFront:self];
        
    }
    
    return self;
}



- (BOOL) canBecomeKeyWindow
{
    return YES;
}

-(BOOL) acceptsMouseMovedEvents
{
    return YES;
}

@end
