//
//  Levenshtein_Wrapper.m
//  Clapper-Rough-Cut
//
//  Created by andrewoch on 14.04.2023.
//

#import "StringsMatcher_Wrapper.h"
#import "StringsMatcher.hpp"

@implementation StringsMatcher_Wrapper

-(NSInteger) Distance: (NSString*)string1 :(NSString*)string2 {
    StringsMatcher matcher;
    NSInteger distance = matcher.LevenshteinDistance([string1 cStringUsingEncoding:NSUTF8StringEncoding], [string2 cStringUsingEncoding:NSUTF8StringEncoding]);
    return distance;
}

@end
