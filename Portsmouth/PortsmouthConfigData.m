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
//  PortsmouthConfigData.m
//  Portsmouth


#import "PortsmouthConfigData.h"

@implementation PortsmouthConfigData

@synthesize isX11SupportEnabled=_isX11SupportEnabled;

@synthesize overlayBackgroundColor=_overlayBackgroundColor;
@synthesize overlayBorderColor=_overlayBorderColor;
@synthesize borderStyle=_borderStyle;
@synthesize cornerRadius=_cornerRadius;
@synthesize borderWidth=_borderWidth;
@synthesize keyCombo=_keyCombo;

@synthesize hotzoneWidthPercentage=_hotzoneWidthPercentage;
//@synthesize hotzoneHeightPercentage=_hotzoneHeightPercentage;

@synthesize defaultTopToFullScreen=_defaultTopToFullScreen;
@synthesize defaultFullScreenToLionFullScreen=_defaultFullScreenToLionFullScreen;
@synthesize displayTargetOverlay=_displayTargetOverlay;

- (id)copyWithZone:(NSZone *)zone
{
    PortsmouthConfigData *copy = [[[self class] allocWithZone: zone] init];

    [copy setBorderStyle:_borderStyle];
    [copy setBorderWidth:_borderWidth];
    [copy setCornerRadius:_cornerRadius];
    [copy setDefaultFullScreenToLionFullScreen:_defaultFullScreenToLionFullScreen];
    [copy setDefaultTopToFullScreen:_defaultTopToFullScreen];
    //[copy setHotzoneHeightPercentage:_hotzoneHeightPercentage];
    [copy setHotzoneWidthPercentage:_hotzoneWidthPercentage];
    [copy setIsX11SupportEnabled:_isX11SupportEnabled];
    [copy setOverlayBackgroundColor:[_overlayBackgroundColor copyWithZone:zone]];
    [copy setOverlayBorderColor:[_overlayBorderColor copyWithZone:zone]];
    [copy setDisplayTargetOverlay:_displayTargetOverlay];
    [copy setKeyCombo:_keyCombo];
	
    return copy;
}

@end
