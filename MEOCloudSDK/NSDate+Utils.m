//
//  NSDate+Utils.m
//  MEOCloudApp
//
//  Created by Luís Silva on 05/02/15.
//
//

#import "NSDate+Utils.h"

@implementation NSDate(Utils)

static NSDateFormatter* dateFormatter = nil;
static NSString* datePattern = nil;

+ (NSDate*)dateFromString:(NSString*)dateString pattern:(NSString*)pattern {
    if (dateString == nil || pattern == nil) return nil;
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }

    if (datePattern == nil || ![datePattern isEqualToString:pattern]) {
        datePattern = pattern;
        dateFormatter.dateFormat = pattern;
    }
    
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    return date;
}

@end
