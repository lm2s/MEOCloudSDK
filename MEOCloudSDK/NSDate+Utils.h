//
//  NSDate+Utils.h
//  MEOCloudApp
//
//  Created by Luís Silva on 05/02/15.
//
//

#import <Foundation/Foundation.h>

@interface NSDate(Utils)
+ (NSDate*)dateFromString:(NSString*)dateString pattern:(NSString*)pattern;
@end
