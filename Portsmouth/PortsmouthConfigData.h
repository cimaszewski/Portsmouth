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
//  PortsmouthConfigData.h
//  Portsmouth


#import <Foundation/Foundation.h>
#import "BorderStyle.h"
#import "ShortcutRecorder.h"

@interface PortsmouthConfigData : NSObject <NSCopying>
{

    BOOL _isX11SupportEnabled;
    BOOL _displayTargetOverlay;
    
    NSColor *_overlayBackgroundColor;
    NSColor *_overlayBorderColor;
    enum BorderStyle _borderStyle;
    float _cornerRadius;
    float _borderWidth;
    
    float _hotzoneWidthPercentage;
    //float _hotzoneHeightPercentage;
	KeyCombo _keyCombo;
    
    BOOL _defaultTopToFullScreen;
    BOOL _defaultFullScreenToLionFullScreen;
	
	KeyCombo _lockScreenKeyCombo;
	KeyCombo _screenSaverKeyCombo;
}

@property BOOL isX11SupportEnabled;
@property BOOL displayTargetOverlay;

@property NSColor *overlayBackgroundColor;
@property NSColor *overlayBorderColor;
@property enum BorderStyle borderStyle;
@property float cornerRadius;
@property float borderWidth;

@property float hotzoneWidthPercentage;
//@property float hotzoneHeightPercentage;

@property BOOL defaultTopToFullScreen;
@property BOOL defaultFullScreenToLionFullScreen;

@property KeyCombo keyCombo;
@property KeyCombo lockScreenKeyCombo;
@property KeyCombo screenSaverKeyCombo;


@end
