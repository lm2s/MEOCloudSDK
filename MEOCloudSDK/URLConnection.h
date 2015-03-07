// SQiShER
// https://gist.github.com/SQiShER/5009086

#import <Foundation/Foundation.h>

@interface URLConnection : NSObject <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) NSNumber* totalBytes;
@property (nonatomic, strong) NSNumber* receivedBytes;

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                          progress:(void (^)( long long bytesReceived,  long long totalBytes))progress
                 returningResponse:(NSURLResponse **)response
                             error:(NSError **)error;

@end