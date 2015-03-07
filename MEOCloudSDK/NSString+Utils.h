//
//  NSString+Utils.h
//  MEOCloudApp
//
//  Created by Luís Silva on 22/01/15.
//
//

#import <Foundation/Foundation.h>

@interface NSString(Utils)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *MD5Digest;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *decodeFromPercentEscapeString;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *encodeToPercentEscapeString;
@end
