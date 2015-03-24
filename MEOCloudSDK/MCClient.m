// MCClient.h
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

#import "MCClient.h"
#import "NSString+Utils.h"
#import "MCShare.h"
#import "MCLink.h"
#import "URLConnection.h"
#import "AFDownloadRequestOperation.h"

NSString* const MCClientErrorDomain = @"com.lm2s.meocloud.sdk.client";

static const NSString* kPublicAPIUrl = @"https://publicapi.meocloud.pt";
static const NSString* kAPIContentUrl = @"https://api-content.meocloud.pt";
static const NSString* kAccountInfoRequest = @"Account/Info";
static const NSString* kMetadataRequest = @"Metadata";
static const NSString* kCreateFolderRequest = @"Fileops/CreateFolder";
static const NSString* kDeletePathRequest = @"Fileops/Delete";
static const NSString* kDownloadFileRequest = @"Files";
static const NSString* kUploadChunkRequest = @"ChunkedUpload";
static const NSString* kUploadCommitRequest = @"CommitChunkedUpload";
static const NSString* kListSharedFoldersRequest = @"ListSharedFolders";
static const NSString* kListLinksRequest = @"ListLinks";
static const NSString* kShareLinkRequest = @"Shares";
static const NSString* kShareFolderRequest = @"ShareFolder";
static const NSString* kRemoveParticipantFromSharedFolderRequest = @"RemoveParticipantFromSharedFolder";
static const NSString* kSetLinkTTLRequest = @"SetLinkTTL";
static const NSString* kDeleteLinkRequest = @"DeleteLink";
static const NSString* kShortenURLRequest = @"ShortenLinkURL";
static const NSString* kDestroyShortURLRequest = @"DestroyShortURL";
static const NSString* kThumbnailsRequest = @"Thumbnails";

@interface MCClient() {
    dispatch_queue_t thumbnails_queue;
    dispatch_queue_t generic_queue;
    dispatch_queue_t uploads_queue;
}
@property (nonatomic, weak) MCSession *session;
@property (nonatomic) NSMutableDictionary *downloads;
@property (nonatomic) NSMutableDictionary *uploads;
@property (nonatomic) NSString* filesCacheDirectory;
@property (nonatomic, strong) NSString* accessType;
@property (nonatomic, strong) NSString* apiVersion;
@end

@implementation MCClient

- (instancetype)initWithSession:(MCSession *)session {
    self = [self init];
    if (self) {
        _session = session;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _downloads = [NSMutableDictionary new];
    _uploads = [NSMutableDictionary new];
    _filesCacheDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"files"];
    thumbnails_queue = dispatch_queue_create("com.lm2s.meocloud.sdk.thumbnails", NULL);
    generic_queue = dispatch_queue_create("com.lm2s.meocloud.sdk.generic", NULL);
    uploads_queue = dispatch_queue_create("com.lm2s.meocloud.sdk.uploads", NULL);
    if (_session.isSandbox) {
        self.accessType = @"sandbox";
    }
    else {
        self.accessType = @"meocloud";
    }
    
    self.apiVersion = @"1";
}

#pragma mark - Information

- (void)userAccountInfo:(void (^)(MCAccount* accountInfo))accountInfo
                failure:(void (^)(NSError* error))failure {
    
    // https://publicapi.meocloud.pt/1/Account/Info
    
    NSString* accountInfoUrl = [NSString stringWithFormat:@"%@/%@/%@", kPublicAPIUrl, self.apiVersion, kAccountInfoRequest];
    
    [_session.networkManager GET:accountInfoUrl
                      parameters:nil
                         success:^(NSURLSessionDataTask *task, id responseObject) {
                             NSDictionary *response = responseObject;
                             MCAccount *account = [[MCAccount alloc] initWithDictionary:response];
                             accountInfo(account);
                         }
                         failure:^(NSURLSessionDataTask *task, NSError *error) {
                             failure(error);
                         }];
}

- (void)metadataAtPath:(NSString*)path
               success:(void (^)(NSArray *metadata))success
               failure:(void (^)(NSError *error))failure {
    
    // https://publicapi.meocloud.pt/1/Metadata/meocloud/[pathname]/?list=true
    
    NSParameterAssert(path != nil);
    
    // IMPROVE: Nasty.. There must be a better way, but NSURL doesn't encode '(' or ')', which generates problems.
    NSString* metadataUrl = [NSString stringWithFormat:@"%@/%@/%@", self.apiVersion, kMetadataRequest, self.accessType];
    metadataUrl = [metadataUrl stringByAppendingString:[path encodeToPercentEscapeString]];
    metadataUrl = [NSString stringWithFormat:@"%@/%@?list=true", kPublicAPIUrl, metadataUrl];
    
    [_session.networkManager GET:metadataUrl
                      parameters:nil
                         success:^(NSURLSessionDataTask *task, id responseObject) {
                             NSDictionary *response = responseObject;
                             NSArray* contents = response[@"contents"];
                             NSMutableArray *files = [NSMutableArray new];
                             
                             for (NSDictionary *item in contents) {
                                 MCMetadata *file = [[MCMetadata alloc] initWithDictionary: item];
                                 [files addObject: file];
                             }

                             success([NSArray arrayWithArray:files]);
                         }
                         failure:^(NSURLSessionDataTask *task, NSError *error) {
                             failure(error);
                         }];

}

#pragma mark - Download

- (void)downloadFileAtPath:(NSString*)path
                  progress:(void (^)(long long bytesRead, long long bytesExpectedToRead))progress
                   success:(void (^)(NSString* path))success
                   failure:(void (^)(NSError* error))failure {
    
    NSParameterAssert(path != nil);
    
    NSString *fileFinalPath = [self.filesCacheDirectory stringByAppendingPathComponent:path];
    
    if ([self isFileCached: path]) {
        success(fileFinalPath);
        return;
    }
    
    // Create intermediary directories if neccessary
    //
    
    NSString *fileFinalPathDirectories = [fileFinalPath stringByDeletingLastPathComponent];
    NSError * errorCreateDirectory = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:fileFinalPathDirectories
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&errorCreateDirectory];
    if (errorCreateDirectory != nil) {
        failure(errorCreateDirectory);
        return;
    }

    // Prepare request
    //
    
    // Nasty.. There must be a better way, but NSURL doesn't encode '(' or ')', which generates problems.
    NSString* url = [NSString stringWithFormat:@"%@/%@/%@", self.apiVersion, kDownloadFileRequest, self.accessType];
    url = [url stringByAppendingPathComponent:[path encodeToPercentEscapeString]];
    url = [NSString stringWithFormat:@"%@/%@", kAPIContentUrl, url];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [_session.networkManager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil error:&serializationError];
    if (serializationError) {
        failure(serializationError);
        return;
    }
    
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request fileIdentifier:[path MD5Digest] targetPath:fileFinalPath shouldResume:YES];
    [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation,
                                                     NSInteger bytesRead,
                                                     long long totalBytesRead,
                                                     long long totalBytesExpected,
                                                     long long totalBytesReadForFile,
                                                     long long totalBytesExpectedToReadForFile) {
        //NSLog(@"progress: %lld kb / %lld kb",totalBytesReadForFile/1024, totalBytesExpectedToReadForFile / 1024);
        progress(totalBytesReadForFile, totalBytesExpectedToReadForFile);
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (operation.error) {
                failure(operation.error);
                return;
            }
            success(fileFinalPath);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    
    (self.downloads)[path] = operation;
    [operation start];
}

- (void)resumeFileDownloadAtPath:(NSString *)path {
    NSParameterAssert(path != nil);
    AFDownloadRequestOperation* operation = (self.downloads)[path];
    if (operation) {
        [operation resume];
    }
}

- (void)pauseFileDownloadAtPath:(NSString *)path {
    NSParameterAssert(path != nil);
    AFDownloadRequestOperation* operation = (self.downloads)[path];
    if (operation) {
        [operation pause];
    }
}

- (void)cancelFileDownloadAtPath:(NSString *)path {
    NSParameterAssert(path != nil);
    AFDownloadRequestOperation* operation = (self.downloads)[path];
    if (operation) {
        [operation cancel];
    }
}


- (void)thumbnailAtPath:(NSString*)path
                   size:(MCThumbnailSize)size
                 format:(MCThumbnailFormat)format
                   crop:(BOOL)crop
                success:(void (^)(UIImage* thumbnail))success
                failure:(void (^)(NSError* error))failure {
    
    // https://api-content.meocloud.pt/1/Thumbnails/[meocloud|sandbox]/[pathname]?params
    // format: jpeg ou png
    // size: xs(32x32) ou s(64x64) ou m(120x120) ou l(640x480) ou xl(1024x768)
    // crop: true ou false
    
    NSString *sizeString;
    switch (size) {
        case MCThumbnailSizeXS:
            sizeString = @"xs";
            break;
        case MCThumbnailSizeS:
            sizeString = @"s";
            break;
        case MCThumbnailSizeM:
            sizeString = @"m";
            break;
        case MCThumbnailSizeL:
            sizeString = @"l";
            break;
        case MCThumbnailSizeXL:
            sizeString = @"xl";
            break;
        default:
            sizeString = @"m";
            break;
    }
    
    NSString *formatString;
    switch (format) {
        case MCThumbnailFormatPNG:
            formatString = @"png";
            break;
        case MCThumbnailFormatJPEG:
            formatString = @"jpeg";
            break;
        default:
            formatString = @"png";
            break;
    }
    
    NSString* cropString = crop ? @"true" : @"false";
    
    dispatch_async(thumbnails_queue, ^{
        // IMPROVE: Nasty.. There must be a better way, but NSURL doesn't encode '(' or ')', which generates problems.
        NSString* url = [NSString stringWithFormat:@"%@/%@/%@", self.apiVersion, kThumbnailsRequest, self.accessType];
        url = [url stringByAppendingPathComponent:[path encodeToPercentEscapeString]];
        url = [NSString stringWithFormat:@"%@/%@", kAPIContentUrl, url];
        
        NSDictionary* queryParams = @{@"format" : formatString, @"size" : sizeString, @"crop" : cropString};
        
        NSError *serializationError = nil;
        NSMutableURLRequest *request = [_session.networkManager.requestSerializer requestWithMethod:@"GET" URLString:url parameters:queryParams error:&serializationError];
        if (serializationError) {
            
        }

        
        NSProgress *progress;
        
        NSURLSessionDownloadTask *task = [_session.networkManager downloadTaskWithRequest:request
                                                                                 progress:&progress
                                                                              destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                                                  return [targetPath URLByAppendingPathExtension:formatString];
                                                                              }
                                                                        completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                                                            if (error) {
                                                                                failure(error);
                                                                            }
                                                                            else {
                                                                                NSData *imageData = [NSData dataWithContentsOfURL:filePath];
                                                                                
                                                                                UIImage *image = [[UIImage alloc] initWithData:imageData scale:[[UIScreen mainScreen] scale]];
                                                                                success(image);
                                                                            }
                                                                        }];
        [task resume];
    });
}

#pragma mark - Upload

- (void)uploadToPath:(NSString*)path
            filename:(NSString*)filename
           overwrite:(BOOL)overwrite
          identifier:(NSString*)identifier
         inputStream:(BOOL (^)(NSString* uploadId, long long offset, NSData **data, BOOL* abortUpload))inputStream
            progress:(void (^)(NSString* uploadId, unsigned long long bytesUploaded, unsigned long long totalToBeUploaded))progress
             success:(void (^)(NSDictionary *metadata))success
             failure:(void (^)(NSError *error))failure {

    // https://api-content.meocloud.pt/1/ChunkedUpload
    // ...
    // https://api-content.meocloud.pt/1/CommitChunkedUpload
    
    NSParameterAssert(path != nil && filename != nil);
    
    dispatch_async(uploads_queue, ^{
        NSString *remotePath = [path stringByAppendingPathComponent:filename];
        
        NSString* chunkBaseUrl = [NSString stringWithFormat:@"%@/%@/%@", kAPIContentUrl, self.apiVersion, kUploadChunkRequest];
        NSString* requestUrl = chunkBaseUrl;
        
        NSString* uploadIdentifier = identifier;
        long long offset = 0;
        NSData* dataChunkToUpload;
        
        // Send the chunks
        //
        
        BOOL shouldAbort = NO;
        
        while (inputStream(uploadIdentifier, offset, &dataChunkToUpload, &shouldAbort)) {
            if (shouldAbort) {
                failure([NSError errorWithDomain:MCClientErrorDomain code:kUploadAbortRequested userInfo:@{@"description" : @"upload abort requested"}]);
                return;
            }
            
            if (uploadIdentifier) {
                requestUrl = [NSString stringWithFormat:@"%@?upload_id=%@&offset=%lld", chunkBaseUrl, uploadIdentifier, offset];
            }
            
            NSError* serializationError = nil;
            NSMutableURLRequest* uploadChunkRequest = [_session.networkManager.requestSerializer requestWithMethod:@"PUT" URLString:requestUrl parameters:nil error:&serializationError];
            if (serializationError) {
                failure(serializationError);
                return;
            }
            [uploadChunkRequest setHTTPBody: dataChunkToUpload];
                        
            NSURLResponse* response;
            NSError* uploadChunkRequestError;
            NSData* responseData = [URLConnection sendSynchronousRequest:uploadChunkRequest
                                                                progress:^(long long bytesTransfered, long long totalBytes) {
                                                                    progress(uploadIdentifier, bytesTransfered, dataChunkToUpload.length);
                                                                }
                                                       returningResponse:&response
                                                                   error:&uploadChunkRequestError];
            if (uploadChunkRequestError) {
                failure(uploadChunkRequestError);
                return;
            }
            
            NSError* jsonDecodeError;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&jsonDecodeError];
            if (jsonDecodeError) {
                failure(jsonDecodeError);
                return;
            }
            
            if (jsonResponse[@"upload_id"]) {
                uploadIdentifier = jsonResponse[@"upload_id"];
            }
            
            if (jsonResponse[@"offset"]) {
                offset = [jsonResponse[@"offset"] longLongValue];
            }
            
        }
        
        // Commit
        //

        // IMPROVE: Nasty.. There must be a better way, but NSURL doesn't encode '(' or ')', which generates problems.
        NSString* commitUrl = [NSString stringWithFormat:@"%@/%@/%@", self.apiVersion, kUploadCommitRequest, self.accessType];
        commitUrl = [commitUrl stringByAppendingPathComponent:[remotePath encodeToPercentEscapeString]];
        commitUrl = [NSString stringWithFormat:@"%@/%@", kAPIContentUrl, commitUrl];
        
        NSDictionary* commitPostParams = @{@"upload_id" : uploadIdentifier,
                                           @"overwrite" : (overwrite ? @"True" : @"False")};
        
        NSError* serializationError = nil;
        NSMutableURLRequest* uploadCommitRequest = [_session.networkManager.requestSerializer requestWithMethod:@"POST" URLString:commitUrl parameters:commitPostParams error:&serializationError];
        if (serializationError) {
            failure(serializationError);
            return;
        }
        
        NSURLResponse* response = nil;
        NSError* uploadCommitRequestError = nil;
        NSData *commitResponseData = [NSURLConnection sendSynchronousRequest:uploadCommitRequest returningResponse:&response error:&uploadCommitRequestError];
        if (uploadCommitRequestError) {
            failure(uploadCommitRequestError);
            return;
        }
        
        NSError* jsonDecodeError;
        NSDictionary *metadata = [NSJSONSerialization JSONObjectWithData:commitResponseData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonDecodeError];
        if (jsonDecodeError) {
            
        }
        
        success(metadata);
    });
}

#pragma mark - File/Folder Operations

- (void)createFolder:(NSString*)folder
              atPath:(NSString*)path
             success:(void (^)(NSDictionary* info))success
             failure:(void (^)(NSError* error))failure {
    
    // https://publicapi.meocloud.pt/1/Fileops/CreateFolder
    
    NSParameterAssert(folder != nil && path != nil);
    
    NSString* createFolderUrl = [NSString stringWithFormat:@"%@/%@/%@", kPublicAPIUrl, self.apiVersion, kCreateFolderRequest];
    
    NSString *folderPath = [path stringByAppendingPathComponent:folder];
    NSDictionary *createFolderParams = @{@"root":self.accessType,
                                         @"path":folderPath};
    
    [_session.networkManager POST:createFolderUrl
                       parameters:createFolderParams
                          success:^(NSURLSessionDataTask *task, id responseObject) {
                              NSDictionary* metadata = responseObject;
                              success(metadata);
                          }
                          failure:^(NSURLSessionDataTask *task, NSError *error) {
                              failure(error);
                          }];
}

- (void)deleteAtPath:(NSString*)path
             success:(void (^)(NSDictionary* metadata))success
             failure:(void (^)(NSError* error))failure {

    // https://publicapi.meocloud.pt/1/Fileops/Delete
    // POST Parameters:
    // - root = meocloud | sandbox
    // - path = ...
    
    NSParameterAssert(path != nil);
    
    NSString *deletePathUrl = [NSString stringWithFormat:@"%@/%@/%@", kPublicAPIUrl, self.apiVersion, kDeletePathRequest];
    NSDictionary* deleteParams = @{@"root" : self.accessType,
                                   @"path" : path};
    
    [_session.networkManager POST:deletePathUrl
                       parameters:deleteParams
                          success:^(NSURLSessionDataTask *task, id responseObject) {
                              NSDictionary* metadata = responseObject;
                              success(metadata);
                          }
                          failure:^(NSURLSessionDataTask *task, NSError *error) {
                              failure(error);
                          }];
}

#pragma mark - Sharing

- (void)sharedFolders:(void (^)(NSArray* folders))sharedFolders
              failure:(void (^)(NSError* error))failure {

    // https://publicapi.meocloud.pt/1/ListSharedFolders
    
    NSString *deletePathUrl = [NSString stringWithFormat:@"%@/%@/%@", kPublicAPIUrl, self.apiVersion, kListSharedFoldersRequest];
    [_session.networkManager GET:deletePathUrl
                       parameters:nil
                          success:^(NSURLSessionDataTask *task, id responseObject) {
                              NSDictionary* sharedInfo = responseObject;
                              NSMutableArray* folders = [NSMutableArray new];
                              for (NSString* identifier in sharedInfo.allKeys) {
                                  MCShare* sharedFolder = [[MCShare alloc] initWithIdentifier:identifier dictionary:sharedInfo[identifier]];
                                  [folders addObject:sharedFolder];
                              }
                              
                              sharedFolders([NSArray arrayWithArray: folders]);
                          }
                          failure:^(NSURLSessionDataTask *task, NSError *error) {
                              failure(error);
                          }];
}

- (void)sharedLinks:(void (^)(NSArray* links))sharedLinks failure:(void (^)(NSError* error))failure {
    // https://publicapi.meocloud.pt/1/ListLinks
    
    NSString *deletePathUrl = [NSString stringWithFormat:@"%@/%@/%@", kPublicAPIUrl, self.apiVersion, kListLinksRequest];
    [_session.networkManager GET:deletePathUrl
                      parameters:nil
                         success:^(NSURLSessionDataTask *task, id responseObject) {
                             NSArray* linksInfo = responseObject;
                             NSMutableArray* links = [NSMutableArray new];
                             for (NSDictionary* link in linksInfo) {
                                 MCLink* sharedLink = [[MCLink alloc] initWithDictionary:link];
                                 [links addObject:sharedLink];
                             }
                             
                             sharedLinks([NSArray arrayWithArray: links]);
                         }
                         failure:^(NSURLSessionDataTask *task, NSError *error) {
                             failure(error);
                         }];
}

- (void)linkForPath:(NSString*)path
            success:(void (^)(NSDictionary* info))success
            failure:(void (^)(NSError* error))failure {
    
    NSParameterAssert(path != nil);
    
    // https://publicapi.meocloud.pt/1/Shares/[meocloud|sandbox]/[pathname]
    
    // IMPROVE: Nasty.. There must be a better way, but NSURL doesn't encode '(' or ')', which generates problems.
    NSString* url = [NSString stringWithFormat:@"%@/%@/%@", self.apiVersion, kShareLinkRequest, self.accessType];
    url = [url stringByAppendingPathComponent:[path encodeToPercentEscapeString]];
    url = [NSString stringWithFormat:@"%@/%@", kPublicAPIUrl, url];
    
    [_session.networkManager POST:url
                      parameters:nil
                         success:^(NSURLSessionDataTask *task, id responseObject) {
                             success(responseObject);
                         }
                         failure:^(NSURLSessionDataTask *task, NSError *error) {
                             failure(error);
                         }];
}

- (void)setLinkTTL:(NSUInteger)ttl
    linkIdentifier:(NSString*)linkIdentifier
           success:(void(^)(void))success
           failure:(void(^)(NSError* error))failure {
    
    // https://publicapi.meocloud.pt/1/SetLinkTTL
    
    NSParameterAssert(linkIdentifier != nil);
    
    NSString *linkTTLUrl = [NSString stringWithFormat:@"%@/%@/%@", kPublicAPIUrl, self.apiVersion, kSetLinkTTLRequest];
    NSDictionary* linkTTLParams = @{@"ttl"      : @(ttl),
                                    @"shareid"  : linkIdentifier};
    
    [_session.networkManager POST:linkTTLUrl
                       parameters:linkTTLParams
                          success:^(NSURLSessionDataTask *task, id responseObject) {
                              success();
                          }
                          failure:^(NSURLSessionDataTask *task, NSError *error) {
                              failure(error);
                          }];
}

- (void)deleteLink:(NSString*)linkIdentifier
           success:(void(^)(void))success
           failure:(void (^)(NSError* error))failure {
    
    // https://publicapi.meocloud.pt/1/DeleteLink
    
    NSParameterAssert(linkIdentifier != nil);
    
    NSString *deleteLinkUrl = [NSString stringWithFormat:@"%@/%@/%@", kPublicAPIUrl, self.apiVersion, kDeleteLinkRequest];
    NSDictionary* deleteLinkParams = @{@"shareid" : linkIdentifier};
    
    [_session.networkManager POST:deleteLinkUrl
                       parameters:deleteLinkParams
                          success:^(NSURLSessionDataTask *task, id responseObject) {
                              success();
                          }
                          failure:^(NSURLSessionDataTask *task, NSError *error) {
                              failure(error);
                          }];
}

- (void)shareFolderAtPath:(NSString*)path
                     with:(NSArray*)emails
                  success:(void (^)(NSDictionary* info, NSError* error))success
                  failure:(void (^)(NSError* error))failure {
    
    NSParameterAssert(path != nil && emails != nil && 0 < emails.count);
    
    // https://publicapi.meocloud.pt/1/ShareFolder/[meocloud|sandbox]/[pathname]
    
    // IMPROVE: Nasty.. There must be a better way, but NSURL doesn't encode '(' or ')', which generates problems.
    NSString* url = [NSString stringWithFormat:@"%@/%@/%@", self.apiVersion, kShareFolderRequest, self.accessType];
    url = [url stringByAppendingPathComponent:[path encodeToPercentEscapeString]];
    url = [NSString stringWithFormat:@"%@/%@", kPublicAPIUrl, url];
    
    dispatch_async(generic_queue, ^{
        NSMutableDictionary* shareInfo = [NSMutableDictionary new];
        NSMutableArray* failingEmails = [NSMutableArray new];
        
        for (NSString* email in emails) {
            NSDictionary* shareParams =  @{@"to_email" : email};
            
            NSError* serializationError = nil;
            NSMutableURLRequest* shareFolderRequest = [_session.networkManager.requestSerializer requestWithMethod:@"POST" URLString:url parameters:shareParams error:&serializationError];
            if (serializationError) {
                failure(serializationError);
                return;
            }
            
            NSURLResponse* response;
            NSError* shareFolderRequestError;
            NSData* responseData = [NSURLConnection sendSynchronousRequest:shareFolderRequest returningResponse:&response error:&shareFolderRequestError];
            if (shareFolderRequestError) {
                failure(shareFolderRequestError);
                return;
            }
            
            NSError* jsonDecodeError;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&jsonDecodeError];
            if (jsonDecodeError) {
                failure(jsonDecodeError);
                return;
            }
            
            if (jsonResponse[@"req_id"]) {
                shareInfo[email] = jsonResponse[@"req_id"];
            }
            else {
                [failingEmails addObject:email];
            }
        }
        
        
        if (shareInfo.count == 0) { // no request was succesful
            NSError* error = [NSError errorWithDomain:MCClientErrorDomain
                                                 code:kShareFolderFailed
                                             userInfo:@{@"description" : @"share request failed for all emails"}];
            failure(error);
        }
        else { // all or some request were successful
            NSError* failEmails = nil;
            if (failingEmails.count > 0) {
                failEmails = [NSError errorWithDomain:MCClientErrorDomain
                                                code:kShareFolderPartialSuccess
                                             userInfo:@{@"description" : @"share request failed for some emails",
                                                        @"emails" : failingEmails}];
            }
            success(shareInfo, failEmails);
        }
    });
}

- (void)removeUserFromShareAtPath:(NSString*)path
                             user:(NSString*)userIdentifier
                          success:(void (^)(void))success
                          failure:(void (^)(NSError* error))failure {
    
    // https://publicapi.meocloud.pt/1/RemoveParticipantFromSharedFolder/[meocloud|sandbox]/[pathname]
    // --
    // POST /1/RemoveParticipantFromSharedFolder/meocloud/stuff/Téstâção
    // PARAMS: participantid=...
    
    NSParameterAssert(path != nil && userIdentifier != nil);
    
    // IMPROVE: Nasty.. There must be a better way, but NSURL doesn't encode '(' or ')', which generates problems.
    NSString* url = [NSString stringWithFormat:@"%@/%@/%@", self.apiVersion, kRemoveParticipantFromSharedFolderRequest, self.accessType];
    url = [url stringByAppendingPathComponent:[path encodeToPercentEscapeString]];
    url = [NSString stringWithFormat:@"%@/%@", kPublicAPIUrl, url];
    
    NSDictionary* removeUserShareParams = @{@"participantid" : userIdentifier};
    
    [_session.networkManager POST:url
                       parameters:removeUserShareParams
                          success:^(NSURLSessionDataTask *task, id responseObject) {
                              success();
                          }
                          failure:^(NSURLSessionDataTask *task, NSError *error) {
                              failure(error);
                          }];
    
}

#pragma mark - Short URLs

- (void)shortURLForShare:(NSString*)shareIdentifier
                 success:(void (^)(NSString* url))success
                 failure:(void (^)(NSError* error))failure {
    
    // https://publicapi.meocloud.pt/1/ShortenLinkURL
    // --
    // POST /1/ShortenLinkURL
    // Post fields: shareid=9a3c9576-37a9-40fd-8f7b-181f4da2f124
    
    NSParameterAssert(shareIdentifier != nil);
    
    NSString *shortURLUrl = [NSString stringWithFormat:@"%@/%@/%@", kPublicAPIUrl, self.apiVersion, kShortenURLRequest];
    NSDictionary* shortURLParams = @{@"shareid" : shareIdentifier};
    
    [_session.networkManager POST:shortURLUrl
                       parameters:shortURLParams
                          success:^(NSURLSessionDataTask *task, id responseObject) {
                              NSDictionary* response = responseObject;
                              NSString* shortURL = response[@"url"];
                              success(shortURL);
                          }
                          failure:^(NSURLSessionDataTask *task, NSError *error) {
                              failure(error);
                          }];
}

- (void)destroyShortURL:(NSString*)shortURL
                success:(void (^)(NSString* shareIdentifier))success
                failure:(void (^)(NSError* error))failure {
    
    // https://publicapi.meocloud.pt/1/DestroyShortURL
    // --
    // POST /1/DestroyShortURL/gbhu3u
    
    NSParameterAssert(shortURL != nil);
    
    NSURL* shortenURL = [NSURL URLWithString:shortURL];
    if (!shortenURL) {
        NSError* error = [NSError errorWithDomain:MCClientErrorDomain code:kInvalidURLError userInfo:@{@"description" : @"invalid/malformed short url"}];
        failure(error);
        return;
    }
    
    NSString* host = [shortenURL host];
    NSString* subdomain = [[host componentsSeparatedByString:@"."] firstObject];
    if (!subdomain) {
        NSError* error = [NSError errorWithDomain:MCClientErrorDomain code:kRetrieveSubdomainError userInfo:@{@"description" : @"error retrieving shorten url subdomain"}];
        failure(error);
        return;
    }
    
    NSString *destroyShortURLUrl = [NSString stringWithFormat:@"%@/%@/%@/%@", kPublicAPIUrl, self.apiVersion, kDestroyShortURLRequest, subdomain];
    
    [_session.networkManager POST:destroyShortURLUrl
                       parameters:nil
                          success:^(NSURLSessionDataTask *task, id responseObject) {
                              NSDictionary* response = responseObject;
                              NSString* shareId = response[@"share_uuid"];
                              success(shareId);
                          }
                          failure:^(NSURLSessionDataTask *task, NSError *error) {
                              failure(error);
                          }];
    
}



#pragma mark - Utils

- (BOOL)isFileCached:(NSString*)path {
    NSString *finalPath = [_filesCacheDirectory stringByAppendingPathComponent:path];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:finalPath];
}

- (void)clearCachedFiles {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = self.filesCacheDirectory;
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@", directory, file] error:&error];
        if (!success || error) {
            // it failed.
        }
    }
    
    [fm removeItemAtPath:directory error:&error];
    [fm removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"Incomplete"] error:&error];
}

#pragma mark - Download Helper


@end
