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
//  WindowTargetData.m
//  Portsmouth


#import "WindowTargetData.h"
#import "WindowTargetConstants.h"

@implementation WindowTargetData


const int HALF_DIVISOR = 2;


-(id)initWithScreenRect:(NSRect)screenRect visibleRect:(NSRect)visibleRect
{
    if (self = [super init]) 
    {
        
        NSLog (@"screen Rect: x: %f, y: %f, width: %f, height: %f", screenRect.origin.x, screenRect.origin.y, screenRect.size.width, screenRect.size.height);
        
        // _bottomLeftWindowRect
        _bottomLeftWindowRect.origin.x = visibleRect.origin.x;
        _bottomLeftWindowRect.origin.y = visibleRect.origin.y;
        _bottomLeftWindowRect.size.width = visibleRect.size.width / HALF_DIVISOR;
        _bottomLeftWindowRect.size.height = visibleRect.size.height / HALF_DIVISOR;
        
        // _bottomRightWindowRect
        _bottomRightWindowRect.origin.x = visibleRect.origin.x + visibleRect.size.width / HALF_DIVISOR;
        _bottomRightWindowRect.origin.y = visibleRect.origin.y;
        _bottomRightWindowRect.size.width = visibleRect.size.width / HALF_DIVISOR;
        _bottomRightWindowRect.size.height = visibleRect.size.height / HALF_DIVISOR;
        
        // _topLeftWindowRect
        _topLeftWindowRect.origin.x = visibleRect.origin.x;
        _topLeftWindowRect.origin.y = visibleRect.origin.y + visibleRect.size.height / HALF_DIVISOR;
        _topLeftWindowRect.size.width = visibleRect.size.width / HALF_DIVISOR;
        _topLeftWindowRect.size.height = visibleRect.size.height / HALF_DIVISOR;
        
        // _topRightWindowRect
        _topRightWindowRect.origin.x = visibleRect.origin.x + visibleRect.size.width / HALF_DIVISOR;
        _topRightWindowRect.origin.y = visibleRect.origin.y + visibleRect.size.height / HALF_DIVISOR;
        _topRightWindowRect.size.width = visibleRect.size.width / HALF_DIVISOR;
        _topRightWindowRect.size.height = visibleRect.size.height / HALF_DIVISOR;
        
        // _leftWindowRect
        _leftWindowRect.origin.x = visibleRect.origin.x;
        _leftWindowRect.origin.y = visibleRect.origin.y;
        _leftWindowRect.size.width = visibleRect.size.width / HALF_DIVISOR;
        _leftWindowRect.size.height = visibleRect.size.height;
        
        // _rightWindowRect
        _rightWindowRect.origin.x = visibleRect.origin.x + visibleRect.size.width / HALF_DIVISOR;
        _rightWindowRect.origin.y = visibleRect.origin.y;
        _rightWindowRect.size.width = visibleRect.size.width / HALF_DIVISOR;
        _rightWindowRect.size.height = visibleRect.size.height;
        
        // fullscreenWindowRect
        _fullscreenWindowRect.origin.x = visibleRect.origin.x;
        _fullscreenWindowRect.origin.y = visibleRect.origin.y;
        _fullscreenWindowRect.size.width = visibleRect.size.width;
        _fullscreenWindowRect.size.height = visibleRect.size.height;
        
        // topWindowRect
        _topWindowRect.origin.x = visibleRect.origin.x;
        _topWindowRect.origin.y = visibleRect.origin.y + visibleRect.size.height / HALF_DIVISOR;
        _topWindowRect.size.width = visibleRect.size.width;
        _topWindowRect.size.height = visibleRect.size.height / HALF_DIVISOR;
        
        // bottomWindowRect
        _bottomWindowRect.origin.x = visibleRect.origin.x;
        _bottomWindowRect.origin.y = visibleRect.origin.y;
        _bottomWindowRect.size.width = visibleRect.size.width;
        _bottomWindowRect.size.height = visibleRect.size.height/ HALF_DIVISOR;

    }
    
    return self;
}

-(id)initWithScreenRect:(NSRect)screenRect visibleRect:(NSRect)visibleRect staticWindowSize:(NSSize)size
{
    if (self = [super init]) 
    {
        
        NSLog (@"screen Rect: x: %f, y: %f, width: %f, height: %f", screenRect.origin.x, screenRect.origin.y, screenRect.size.width, screenRect.size.height);
        
    
        // _bottomLeftWindowRect
        _bottomLeftWindowRect.origin.x = visibleRect.origin.x;
        _bottomLeftWindowRect.origin.y = visibleRect.origin.y;
        _bottomLeftWindowRect.size.width = size.width;
        _bottomLeftWindowRect.size.height = size.height;
        
        // _bottomRightWindowRect
        _bottomRightWindowRect.origin.x = visibleRect.origin.x + visibleRect.size.width-size.width;
        _bottomRightWindowRect.origin.y = visibleRect.origin.y;
        _bottomRightWindowRect.size.width = size.width;
        _bottomRightWindowRect.size.height = size.height;
        
        // _topLeftWindowRect
        _topLeftWindowRect.origin.x = visibleRect.origin.x;
        _topLeftWindowRect.origin.y = visibleRect.origin.y + visibleRect.size.height-size.height;
        _topLeftWindowRect.size.width = size.width;
        _topLeftWindowRect.size.height = size.height;
        
        // _topRightWindowRect
        _topRightWindowRect.origin.x = visibleRect.origin.x + visibleRect.size.width-size.width;
        _topRightWindowRect.origin.y = visibleRect.origin.y + visibleRect.size.height-size.height;
        _topRightWindowRect.size.width = size.width;
        _topRightWindowRect.size.height = size.height;
        
        // _leftWindowRect
        _leftWindowRect.origin.x = visibleRect.origin.x;
        _leftWindowRect.origin.y = visibleRect.origin.y + ((visibleRect.size.height-size.height)/HALF_DIVISOR);
        _leftWindowRect.size.width = size.width;
        _leftWindowRect.size.height = size.height;
        
        // _rightWindowRect
        _rightWindowRect.origin.x = visibleRect.origin.x + visibleRect.size.width-size.width;
        _rightWindowRect.origin.y = visibleRect.origin.y + ((visibleRect.size.height-size.height)/HALF_DIVISOR);
        _rightWindowRect.size.width = size.width;
        _rightWindowRect.size.height = size.height;
        
        // fullscreenWindowRect
        _fullscreenWindowRect.origin.x = visibleRect.origin.x + ((visibleRect.size.width-size.width)/HALF_DIVISOR);
        _fullscreenWindowRect.origin.y = visibleRect.origin.y + ((visibleRect.size.height-size.height)/HALF_DIVISOR);
        _fullscreenWindowRect.size.width = size.width;
        _fullscreenWindowRect.size.height = size.height;
        
        // topWindowRect
        _topWindowRect.origin.x = visibleRect.origin.x + (visibleRect.size.width - size.width)/ HALF_DIVISOR;
        _topWindowRect.origin.y = visibleRect.origin.y + visibleRect.size.height-size.height;
        _topWindowRect.size.width = size.width;
        _topWindowRect.size.height = size.height;
        
        // bottomWindowRect
        _bottomWindowRect.origin.x = visibleRect.origin.x + (visibleRect.size.width - size.width)/ HALF_DIVISOR;
        _bottomWindowRect.origin.y = visibleRect.origin.y;
        _bottomWindowRect.size.width = size.width;
        _bottomWindowRect.size.height = size.height;
        
    }
    
    return self;
}

-(NSRect)fetchWindowTarget:(WindowTargetConstant)target
{
    switch(target)
    {
        case kBottomLeftWindowTarget:
            return _bottomLeftWindowRect;
        case kBottomRightWindowTarget:
            return _bottomRightWindowRect;
        case kTopLeftWindowTarget:
            return _topLeftWindowRect;
        case kTopRightWindowTarget:
            return _topRightWindowRect;
        case kBottomWindowTarget:
            return _bottomWindowRect;
        case kTopWindowTarget:
            return _topWindowRect;
        case kLeftWindowTarget:
            return _leftWindowRect;
        case kRightWindowTarget:
            return _rightWindowRect;
        case kFullScreenWindowTarget:
            return _fullscreenWindowRect;
        default:
            return NSZeroRect;
    }
}


@end
