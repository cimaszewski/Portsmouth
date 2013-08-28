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
//  WindowHotzoneData.m
//  Portsmouth


#import "WindowHotzoneData.h"
#import "WindowTargetConstants.h"

@implementation WindowHotzoneData

@synthesize config=_config;


-(void)calculateHotzones
{
    // bottomLeftHotzone
    _bottomLeftHotzone.origin.x = _screenRect.origin.x - 1;
    _bottomLeftHotzone.origin.y = _screenRect.origin.y - 1;
    _bottomLeftHotzone.size.width = (_screenRect.size.width * self.config.hotzoneWidthPercentage) + 2;
    _bottomLeftHotzone.size.height = (_screenRect.size.height * self.config.hotzoneWidthPercentage) + 2;
    
    // bottomRightHotzone
    _bottomRightHotzone.origin.x = _screenRect.origin.x + _screenRect.size.width - (_screenRect.size.width * self.config.hotzoneWidthPercentage) - 1;
    _bottomRightHotzone.origin.y = _screenRect.origin.y - 1;
    _bottomRightHotzone.size.width = (_screenRect.size.width * self.config.hotzoneWidthPercentage) + 2;
    _bottomRightHotzone.size.height = (_screenRect.size.height * self.config.hotzoneWidthPercentage) + 2;
    
    // topLeftHotzone
    _topLeftHotzone.origin.x = _screenRect.origin.x - 1;
    _topLeftHotzone.origin.y = _screenRect.origin.y + _screenRect.size.height - (_screenRect.size.height * self.config.hotzoneWidthPercentage) - 1;
    _topLeftHotzone.size.width = (_screenRect.size.width * self.config.hotzoneWidthPercentage) + 2;
    _topLeftHotzone.size.height = (_screenRect.size.height * self.config.hotzoneWidthPercentage) + 2;
    
    // topRightHotzone
    _topRightHotzone.origin.x = _screenRect.origin.x + _screenRect.size.width - (_screenRect.size.width * self.config.hotzoneWidthPercentage) - 1;
    _topRightHotzone.origin.y = _screenRect.origin.y + _screenRect.size.height - (_screenRect.size.height * self.config.hotzoneWidthPercentage) - 1;
    _topRightHotzone.size.width = (_screenRect.size.width * self.config.hotzoneWidthPercentage) + 2;
    _topRightHotzone.size.height = (_screenRect.size.height * self.config.hotzoneWidthPercentage) + 2;
    
    // leftHotzone
    _leftHotzone.origin.x = _screenRect.origin.x - 1;
    _leftHotzone.origin.y = _screenRect.origin.y + (_screenRect.size.height * self.config.hotzoneWidthPercentage) - 1;
    _leftHotzone.size.width = (_screenRect.size.width * self.config.hotzoneWidthPercentage) + 2;
    _leftHotzone.size.height = _screenRect.size.height - (2 * _screenRect.size.height * self.config.hotzoneWidthPercentage) + 2;
    
    // rightHotzone
    _rightHotzone.origin.x = _screenRect.origin.x + _screenRect.size.width - (_screenRect.size.width * self.config.hotzoneWidthPercentage) - 1;
    _rightHotzone.origin.y = _screenRect.origin.y + (_screenRect.size.height * self.config.hotzoneWidthPercentage) - 1;
    _rightHotzone.size.width = (_screenRect.size.width * self.config.hotzoneWidthPercentage) + 2;
    _rightHotzone.size.height = _screenRect.size.height - (2 * _screenRect.size.height * self.config.hotzoneWidthPercentage) + 1;
    
    // fullscreenHotzone
    _topHotzone.origin.x = _screenRect.origin.x + (_screenRect.size.width * self.config.hotzoneWidthPercentage);
    _topHotzone.origin.y = _screenRect.origin.y + _screenRect.size.height - (_screenRect.size.height * self.config.hotzoneWidthPercentage) - 1;
    _topHotzone.size.width = _screenRect.size.width - (2 * _screenRect.size.width * self.config.hotzoneWidthPercentage);
    _topHotzone.size.height = (_screenRect.size.height * self.config.hotzoneWidthPercentage) + 2;
    
    // bottomHotzone
    _bottomHotzone.origin.x = _screenRect.origin.x + (_screenRect.size.width * self.config.hotzoneWidthPercentage);
    _bottomHotzone.origin.y = _screenRect.origin.y - 1;
    _bottomHotzone.size.width = _screenRect.size.width - (2 * _screenRect.size.width * self.config.hotzoneWidthPercentage);
    _bottomHotzone.size.height = (_screenRect.size.height * self.config.hotzoneWidthPercentage) + 2;
}

-(id)initWithScreenRect:(NSRect)screenRect configuration:(PortsmouthConfigData *)configuration
{
    if (self = [super init])
    {
        
        NSLog (@"screen Rect: x: %f, y: %f, width: %f, height: %f", screenRect.origin.x, screenRect.origin.y, screenRect.size.width, screenRect.size.height);
        
        self.config = configuration;
        
        _screenRect = screenRect;
        
        [self calculateHotzones];
       
    }
    
    return self;
}

-(WindowTargetConstant)fetchTargetForHotzonePoint:(NSPoint) point
{
    if (NSPointInRect(point, _topLeftHotzone))
    {
        return kTopLeftWindowTarget;
    }
    else if (NSPointInRect(point, _topRightHotzone))
    {
        return kTopRightWindowTarget;
    }
    else if (NSPointInRect(point, _bottomLeftHotzone))
    {
        return kBottomLeftWindowTarget;
    }
    else if (NSPointInRect(point, _bottomRightHotzone))
    {
        return kBottomRightWindowTarget;
    }
    else if (NSPointInRect(point, _leftHotzone))
    {
        return kLeftWindowTarget;
    }
    else if (NSPointInRect(point, _rightHotzone))
    {
       return kRightWindowTarget;
    }
    else if (NSPointInRect(point, _topHotzone))
    {
        return kTopWindowTarget;
    }
    else if (NSPointInRect(point, _bottomHotzone))
    {
        return kBottomWindowTarget;
    }
    else
    {
        return kNoWindowTarget;
    }
}




@end
