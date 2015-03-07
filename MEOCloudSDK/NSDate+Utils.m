// NSDate+Utils.h
//
// Copyright (c) 2015 Luís M. Marques Silva
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
