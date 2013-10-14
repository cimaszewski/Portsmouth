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
//  ScreenSaverExecutionController.m
//  Portsmouth


#import "HotKeyController.h"
#import "Portsmouth.h"
#import "WindowMoverController.h"

@implementation HotKeyController

@synthesize windowMoverController=_windowMoverController;

const int HOTKEY_EVENTID_WINDOWMOVER = 1;
const int HOTKEY_EVENTID_SCREENSAVER = 2;
const int HOTKEY_EVENTID_LOCKSCREEN = 3;

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,
                       void *userData)
{
    
    if(GetEventKind(theEvent) == kEventHotKeyPressed)
    {
		EventHotKeyID hkCom;
		GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,
						  sizeof(hkCom),NULL,&hkCom);
		
		int l = hkCom.id;
	
        
		if (l == HOTKEY_EVENTID_WINDOWMOVER)
		{
			HotKeyController* controller = (__bridge HotKeyController *)userData;
			controller.windowMoverController.config = controller.config;  // for some reason we lose the configuration in the controller
			[controller.windowMoverController openModal];
		}
		else if (l == HOTKEY_EVENTID_SCREENSAVER)
		{
			NSString *script=@"tell application \"ScreenSaverEngine\" \
			\nactivate \
			\nend tell";
			NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:script];
			[appleScript executeAndReturnError:nil];
		}
		else if (l == HOTKEY_EVENTID_LOCKSCREEN)
		{
			NSTask *task;
			NSMutableArray *arguments = [NSArray arrayWithObject:@"-suspend"];
			
			task = [[NSTask alloc] init];
			[task setArguments: arguments];
			[task setLaunchPath: @"/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession"];
			[task launch];
		}
		
    }
    else if(GetEventKind(theEvent) == kEventHotKeyReleased)
    {
        
		EventHotKeyID hkCom;
		GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,
						  sizeof(hkCom),NULL,&hkCom);
		int l = hkCom.id;
		
		if (l == HOTKEY_EVENTID_WINDOWMOVER)
		{
			HotKeyController* controller = (__bridge HotKeyController *)userData;
			
			if (!controller.windowMoverController.isWindowSelected)
			{
                [controller.windowMoverController closeModalWithSelection:NO];
			}
		}
        
    }
	
    
    return noErr;
}


-(id) initWithConfig:(PortsmouthConfigData*)configuration andWindowMoverController:(WindowMoverController*)controller
{
    if (![super init]) {
		return nil;
    }
    
	_windowMoverController = controller;
    
    _selfRef = CFBridgingRetain(self);
    
	_config = configuration;
    
    const EventTypeSpec hotKeyEvents[] = {{kEventClassKeyboard,kEventHotKeyPressed},{kEventClassKeyboard,kEventHotKeyReleased}};
    InstallApplicationEventHandler(NewEventHandlerUPP(hotKeyHandler),GetEventTypeCount(hotKeyEvents),hotKeyEvents,(void*)_selfRef,NULL);
    
    [self setupHotKeyBinding];
    
    return self;
}



-(void)setupHotKeyBinding
{
	if (_showModalHotKeyRef == nil && _config != nil && _config.keyCombo.code != 0 && _config.keyCombo.flags != 0)
	{
		_hotKeyID.signature='smhk';
		_hotKeyID.id=HOTKEY_EVENTID_WINDOWMOVER;
		
		RegisterEventHotKey((UInt32)_config.keyCombo.code, (UInt32)SRCocoaToCarbonFlags(_config.keyCombo.flags), _hotKeyID,
							GetApplicationEventTarget(), 0, &_showModalHotKeyRef);
	}
	
	if (_screenSaverHotKeyRef == nil && _config != nil && _config.screenSaverKeyCombo.code != 0 && _config.screenSaverKeyCombo.flags != 0)
	{
		_screenSaverKeyID.signature='sshk';
		_screenSaverKeyID.id=HOTKEY_EVENTID_SCREENSAVER;
		
		RegisterEventHotKey((UInt32)_config.screenSaverKeyCombo.code, (UInt32)SRCocoaToCarbonFlags(_config.screenSaverKeyCombo.flags), _screenSaverKeyID,
							GetApplicationEventTarget(), 0, &_screenSaverHotKeyRef);
	}
	
	if (_lockScreenHotKeyRef == nil && _config != nil && _config.lockScreenKeyCombo.code != 0 && _config.lockScreenKeyCombo.flags != 0)
	{
		_lockScreenKeyID.signature='lshk';
		_lockScreenKeyID.id=HOTKEY_EVENTID_LOCKSCREEN;
		
		RegisterEventHotKey((UInt32)_config.lockScreenKeyCombo.code, (UInt32)SRCocoaToCarbonFlags(_config.lockScreenKeyCombo.flags), _lockScreenKeyID,
							GetApplicationEventTarget(), 0, &_lockScreenHotKeyRef);
	}
}

-(void)removeHotKeyBinding
{
	if (_showModalHotKeyRef)
    {
        OSStatus error = UnregisterEventHotKey(_showModalHotKeyRef);
        if(error){
            //handle error
        }
        _showModalHotKeyRef = nil;
    }
	
    if (_screenSaverHotKeyRef)
    {
        OSStatus error = UnregisterEventHotKey(_screenSaverHotKeyRef);
        if(error){
            //handle error
        }
        _screenSaverHotKeyRef = nil;
    }
	if (_lockScreenHotKeyRef)
    {
        OSStatus error = UnregisterEventHotKey(_lockScreenHotKeyRef);
        if(error){
            //handle error
        }
        _lockScreenHotKeyRef = nil;
    }
}

-(void) dealloc
{
    if (_selfRef)
    {
        CFBridgingRelease(_selfRef);
    }
    
    [self removeHotKeyBinding];
}

-(void)pause
{
    log4Debug(@"ScreenSaverExecutionController is Paused...");
    [self removeHotKeyBinding];
    
}

-(void)unpause
{
    log4Debug(@"ScreenSaverExecutionController is unPaused...");
    [self setupHotKeyBinding];
}

@end
