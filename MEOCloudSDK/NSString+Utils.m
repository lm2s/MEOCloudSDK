//
//  NSString+Utils.m
//  MEOCloudApp
//
//  Created by Luís Silva on 22/01/15.
//
//

#import "NSString+Utils.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString(Utils)
- (NSString *)MD5Digest
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

// Encode a string to embed in an URL.
- (NSString*)encodeToPercentEscapeString {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef) self,
                                            NULL,
                                            (CFStringRef) @"!*'();:@&=+$,?%#[]",
                                            kCFStringEncodingUTF8));
}

// Decode a percent escape encoded string.
- (NSString*)decodeFromPercentEscapeString {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                            (CFStringRef)self,
                                                            CFSTR(""),
                                                            kCFStringEncodingUTF8));
}


@end
