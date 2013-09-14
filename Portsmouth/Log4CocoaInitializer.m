//
//  Log4CocoaInitializer.m
//  Portsmouth
//
//  Created by Christopher Cimaszewski on 9/14/13.
//  Copyright (c) 2013 Ninjaerobics. All rights reserved.
//

#import "Log4CocoaInitializer.h"

@implementation Log4CocoaInitializer

+ (void) createFileAppender {
	
	NSString *filename = [[NSBundle bundleForClass:[self class]] pathForResource:@"log4cocoa" ofType:@"properties"];
	L4PropertyConfigurator *configurator = [[L4PropertyConfigurator alloc] initWithFileName:filename];
	[configurator configure];
	
	
	log4Info(@"The logging system has been initialized.");
	
}

@end
