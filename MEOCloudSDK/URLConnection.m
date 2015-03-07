// SQiShER
// https://gist.github.com/SQiShER/5009086

#import "URLConnection.h"

typedef void (^ProgressBlock)( long long bytesReceived,  long long totalBytes);

@interface URLConnection ()
@property(nonatomic, strong) NSURLConnection *connection;
@property(nonatomic, strong) NSURLResponse *response;
@property(nonatomic, strong) NSData *responseData;
@property(nonatomic, strong) NSCondition *condition;
@property(nonatomic, strong) NSError *error;
@property(nonatomic) BOOL connectionDidFinishLoading;
@property(nonatomic, strong) ProgressBlock progressBlock;
@property(nonatomic, readwrite) long long total;
@property(nonatomic, readwrite) long long received;
@end

@implementation URLConnection

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                          progress:(void (^)( long long bytesReceived, long long totalBytes))progress
                 returningResponse:(NSURLResponse **)response
                             error:(NSError **)error {
    
    URLConnection* conn = [[URLConnection alloc] init];
    conn.progressBlock = progress;
    return [conn sendSynchronousRequest:request returningResponse:response error:error];
}

- (id)init {
    self = [super init];
    if (self) {
        self.condition = [[NSCondition alloc] init];
        self.connection = nil;
        self.connectionDidFinishLoading = NO;
        self.error = nil;
        self.response = nil;
        self.responseData = [NSData data];
        self.received = 0;
    }
    return self;
}

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(NSURLResponse **)response
                             error:(NSError **)error {
    NSParameterAssert(request);
    NSAssert(!self.connection, @"This method may only be called once");
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];

    [self.connection setDelegateQueue:[[NSOperationQueue alloc] init]];
    [self.connection start];
    [self waitForConnectionToFinishLoading];
    if (self.error != nil) {
        if (response) *response = nil;
        if (error) *error = self.error;
        return nil;
    } else {
        if (response) *response = self.response;
        if (error) *error = nil;
        return self.responseData;
    }
}

- (void)waitForConnectionToFinishLoading {
    [self.condition lock];
    while (!self.connectionDidFinishLoading) {
        [self.condition wait];
    }
    [self.condition unlock];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.response = response;
    self.total = response.expectedContentLength;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
//    NSLog(@"Uploaded %d,  %d (%ld)", bytesWritten, totalBytesWritten, self.received);
    self.progressBlock(bytesWritten, totalBytesExpectedToWrite);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSMutableData *mutableResponse = self.responseData.mutableCopy;
    [mutableResponse appendData:data];
    self.responseData = mutableResponse.copy;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.condition lock];
    self.error = error;
    self.connectionDidFinishLoading = YES;
    [self.condition signal];
    [self.condition unlock];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.condition lock];
    self.connectionDidFinishLoading = YES;
    [self.condition signal];
    [self.condition unlock];
}

@end