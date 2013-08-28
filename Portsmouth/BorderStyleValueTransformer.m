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
//  BorderStyleValueTransformer.m
//  Portsmouth


#import "BorderStyleValueTransformer.h"
#import "BorderStyle.h"

@implementation BorderStyleValueTransformer

+ (Class)transformedValueClass { return [NSString class]; }

- (id)transformedValue:(id)value {
    enum BorderStyle borderStyle = [value intValue];
    if (borderStyle == noborder)
        return @"None";
    else if (borderStyle == solid)
        return @"Solid";
    else if (borderStyle == shortDash)
        return @"Short Dash";
    else if (borderStyle == longDash)
        return @"Long Dash";
    else if (borderStyle == alternatingDash)
        return @"Alternating";
    
    return nil;
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)reverseTransformedValue:(id)value {
    if ([@"None" isEqualToString:value])
        return [NSNumber numberWithInt: noborder];
    else if ([@"Solid" isEqualToString:value])
        return [NSNumber numberWithInt: solid];
    else if ([@"Short Dash" isEqualToString:value])
        return [NSNumber numberWithInt: shortDash];
    else if ([@"Long Dash" isEqualToString:value])
        return [NSNumber numberWithInt: longDash];
    else if ([@"Alternating" isEqualToString:value])
        return [NSNumber numberWithInt: alternatingDash];
    
    return nil;
}

@end
