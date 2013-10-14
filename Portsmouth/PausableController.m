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
//  PausableController.m
//  Portsmouth


#import "PausableController.h"
#import "Portsmouth.h"


NSString *const NOTIFICATION_PAUSE_EVENTS = @"com.ninjaerobics.Portsmouth.notifications.pauseEvents";
NSString *const NOTIFICATION_UNPAUSE_EVENTS = @"com.ninjaerobics.Portsmouth.notifications.unpauseEvents";



NSString *const NOTIFICATION_MENU_TRACK_BEGIN = @"com.apple.HIToolbox.beginMenuTrackingNotification";
NSString *const NOTIFICATION_MENU_TRACK_END = @"com.apple.HIToolbox.endMenuTrackingNotification";

@implementation PausableController

-(PausableController*) init
{
    if (self = [super init])
    {
        
        _notificationCenter = [NSNotificationCenter defaultCenter];
        [_notificationCenter addObserver:self selector:@selector(pauseEvents:) name:NOTIFICATION_PAUSE_EVENTS object:nil];
        [_notificationCenter addObserver:self selector:@selector(unpauseEvents:) name:NOTIFICATION_UNPAUSE_EVENTS object:nil];
        
        _distNotificationCenter = [NSDistributedNotificationCenter defaultCenter];
        [_distNotificationCenter addObserver:self selector:@selector(pauseEvents:) name:NOTIFICATION_MENU_TRACK_BEGIN object:nil];
        [_distNotificationCenter addObserver:self selector:@selector(unpauseEvents:) name:NOTIFICATION_MENU_TRACK_END object:nil];
        
    }
    
    return self;
}

-(void)pauseEvents:(NSNotification *) notification 
{
    _pauseCounter++;
    [self pause];
}

-(void)unpauseEvents:(NSNotification *) notification 
{
    _pauseCounter = (--_pauseCounter < 0) ? 0 : _pauseCounter;
    if (!_pauseCounter)
    {
        [self unpause];
    }
}


-(void)pause
{
    [self doesNotRecognizeSelector:_cmd];
}

-(void)unpause
{
    [self doesNotRecognizeSelector:_cmd];
}

-(void)dealloc
{
    if (_notificationCenter != nil)
    {
        [_notificationCenter removeObserver:self];
    }
    if (_distNotificationCenter != nil)
    {
        [_distNotificationCenter removeObserver:self];
    }
}

@end
