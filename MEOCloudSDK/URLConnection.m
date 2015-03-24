// URLConnection.h
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
//
// Based on SQiShER gist: https://gist.github.com/SQiShER/5009086

#import "URLConnection.h"

typedef void (^ProgressBlock)( long long bytesReceived,  long long totalBytes);

@interface URLConnection ()
@property(NS_NONATOMIC_IOSONLY, strong) NSURLConnection *connection;
@property(NS_NONATOMIC_IOSONLY, strong) NSURLResponse *response;
@property(NS_NONATOMIC_IOSONLY, strong) NSData *responseData;
@property(NS_NONATOMIC_IOSONLY, strong) NSCondition *condition;
@property(NS_NONATOMIC_IOSONLY, strong) NSError *error;
@property(NS_NONATOMIC_IOSONLY) BOOL connectionDidFinishLoading;
@property(NS_NONATOMIC_IOSONLY, strong) ProgressBlock progressBlock;
@property(NS_NONATOMIC_IOSONLY, readwrite) long long total;
@property(NS_NONATOMIC_IOSONLY, readwrite) long long received;
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

- (instancetype)init {
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