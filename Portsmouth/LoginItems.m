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
//  LoginItemController.m
//  Portsmouth


#import "LoginItems.h"

#import "PortsmouthDefines.h"

@interface LoginItems (Private)

- (id)initWithLoginItemsType:(CFStringRef)type;
- (LSSharedFileListItemRef) getApplicationLoginItemWithPath:(NSString *)path;

@end

// following is just to simplify the code
// not sure whether the is a better way to do that
// this will reuse the SINGLETON_BOILERPLATE* macros
// so less typing while maintaining all the properties of these singletons

@interface GlobalLoginItems : LoginItems

+ (GlobalLoginItems *) _sharedGlobalLoginItems;

@end

@interface SessionLoginItems : LoginItems

+ (SessionLoginItems *) _sharedSessionLoginItems;

@end


@implementation LoginItems

@synthesize type = _type;


- (id)initWithLoginItemsType:(CFStringRef)typed {
	
	if (![super init]) {
		return nil;
	}
	
	_type = typed;
	
	return self;
}


- (BOOL) isInLoginItemsApplicationWithPath:(NSString *)path {
	return [self getApplicationLoginItemWithPath:path] != nil;
}

// following code has been inspired from Growl sources
// http://growl.info/source.php
- (void) toggleApplicationInLoginItemsWithPath:(NSString *)path enabled:(BOOL)enabled {
	
	OSStatus status;
	LSSharedFileListItemRef existingItem = [self getApplicationLoginItemWithPath:path];
	CFURLRef URLToApp = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, true);
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,_type, NULL);
	
	if (enabled && (existingItem == NULL)) {
		NSString *displayName = [[NSFileManager defaultManager] displayNameAtPath:path];
		IconRef icon = NULL;
		FSRef ref;
		Boolean gotRef = CFURLGetFSRef(URLToApp, &ref);
		if (gotRef) {
			status = GetIconRefFromFileInfo(&ref,
											/*fileNameLength*/ 0, /*fileName*/ NULL,
											kFSCatInfoNone, /*catalogInfo*/ NULL,
											kIconServicesNormalUsageFlag,
											&icon,
											/*outLabel*/ NULL);
			if (status != noErr)
				icon = NULL;
		}
		
		LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst, (CFStringRef)CFBridgingRetain(displayName), icon, URLToApp, /*propertiesToSet*/ NULL, /*propertiesToClear*/ NULL);
	} else if (!enabled && (existingItem != NULL)) {
		LSSharedFileListItemRemove(loginItems, existingItem);
	}
}

#pragma mark Private methods

- (LSSharedFileListItemRef) getApplicationLoginItemWithPath:(NSString *)path {
	
	CFURLRef URLToApp = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, true);
	
	LSSharedFileListItemRef existingItem = NULL;
	UInt32 seed = 0U;
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,_type, NULL);
	NSArray *currentLoginItems = CFBridgingRelease((LSSharedFileListCopySnapshot(loginItems, &seed)));
	
	for (id itemObject in currentLoginItems) {
		LSSharedFileListItemRef item = (LSSharedFileListItemRef)CFBridgingRetain(itemObject);
		
		UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
		CFURLRef URL = NULL;
		OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
		if (err == noErr) {
			Boolean foundIt = CFEqual(URL, URLToApp);
			CFRelease(URL);
			
			if (foundIt)
				existingItem = item;
			break;
		}
	}
	
	CFRelease(URLToApp);
	
	return existingItem;
}

+ (LoginItems *) sharedGlobalLoginItems {
	return [GlobalLoginItems _sharedGlobalLoginItems];
}

+ (LoginItems *) sharedSessionLoginItems {
	return [SessionLoginItems _sharedSessionLoginItems];
}
@end

@implementation GlobalLoginItems

SINGLETON_BOILERPLATE_FULL(GlobalLoginItems, _sharedGlobalLoginItems, initWithLoginItemsType:kLSSharedFileListGlobalLoginItems);

@end

@implementation SessionLoginItems

SINGLETON_BOILERPLATE_FULL(SessionLoginItems, _sharedSessionLoginItems, initWithLoginItemsType:kLSSharedFileListSessionLoginItems);

@end