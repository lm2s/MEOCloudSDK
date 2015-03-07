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

#import <Foundation/Foundation.h>
#import "MCSession.h"
#import "MCMetadata.h"
#import "MCAccount.h"

extern NSString* const MCClientErrorDomain;

typedef NS_ENUM(NSInteger, MCClientError) {
    kInvalidURLError = -1,
    kRetrieveSubdomainError = -2,
    kShareFolderFailed = -3,
    kShareFolderPartialSuccess = -4,
    kUploadAbortRequested = -5
};

typedef NS_ENUM(NSInteger, MCThumbnailSize) {
    MCThumbnailSizeXS,
    MCThumbnailSizeS,
    MCThumbnailSizeM,
    MCThumbnailSizeL,
    MCThumbnailSizeXL
};

typedef NS_ENUM(NSInteger, MCThumbnailFormat) {
    MCThumbnailFormatJPEG,
    MCThumbnailFormatPNG
};

// - TO REMOVE
@protocol MCClientDelegate <NSObject>

@end
// -


/**
 * This class exposes the MEOCloud API functionality. 
 *
 * It allows the retrieval of metadata,
 * file and folder manipulation, file download and upload, generation of sharing links for files
 * and folders, invitation of other users to collaborate in a folder, manipulation of shared folders
 * options, etc.
 *
 * For use of this class, first create a session and then use the initWithSession method to
 * create an instance of this class.
 */
@interface MCClient : NSObject

@property (nonatomic, weak) id<MCClientDelegate> delegate;

- (instancetype)initWithSession:(MCSession*)session;
- (void)userAccountInfo:(void (^)(MCAccount* accountInfo))accountInfo failure:(void (^)(NSError* error))failure;

- (void)metadataAtPath:(NSString*)path
               success:(void (^)(NSArray *metadata))success
               failure:(void (^)(NSError *error))failure;

// TODO
- (void)metadataAtPath:(NSString*)path
              contents:(BOOL)contents
               success:(void (^)(NSArray *metadata))success
               failure:(void (^)(NSError *error))failure;

- (void)downloadFileAtPath:(NSString*)path
                  progress:(void (^)(long long bytesRead, long long bytesExpectedToRead))progress
                   success:(void (^)(NSString* path))success
                   failure:(void (^)(NSError* error))failure;
- (void)resumeFileDownloadAtPath:(NSString *)path;
- (void)pauseFileDownloadAtPath:(NSString*)path;
- (void)cancelFileDownloadAtPath:(NSString*)path;

- (BOOL)isFileCached:(NSString*)path;
- (void)clearCachedFiles;

// TODO
- (void)thumbnailForFile:(MCMetadata*)fileMetadata
                    size:(MCThumbnailSize)size
                  format:(MCThumbnailFormat)format
                    crop:(BOOL)crop
                 success:(void (^)(UIImage* thumbnailImage))success
                 failure:(void (^)(NSError* error))failure;

- (void)createFolder:(NSString*)folder
              atPath:(NSString*)path
             success:(void (^)(NSDictionary* info))success
             failure:(void (^)(NSError* error))failure;
// TODO
- (void)uploadToPath:(NSString*)path
            filename:(NSString*)filename
                data:(NSData*)data
            progress:(void (^)(unsigned long long bytesUploaded, unsigned long long totalToBeUploaded))progress
             success:(void (^)(NSDictionary *metadata))success
             failure:(void (^)(NSError *error))failure;

- (void)uploadToPath:(NSString*)path
            filename:(NSString*)filename
           overwrite:(BOOL)overwrite
          identifier:(NSString*)identifier
         inputStream:(BOOL (^)(NSString* uploadId, long long offset, NSData **data, BOOL* abortUpload))inputStream
            progress:(void (^)(NSString* uploadId, unsigned long long bytesUploaded, unsigned long long totalToBeUploaded))progress
             success:(void (^)(NSDictionary *metadata))success
             failure:(void (^)(NSError *error))failure;

- (void)deleteAtPath:(NSString*)path
             success:(void (^)(NSDictionary* metadata))success
             failure:(void (^)(NSError* error))failure;

- (void)sharedFolders:(void (^)(NSArray* folders))sharedFolders
              failure:(void (^)(NSError*))failure;

- (void)sharedLinks:(void (^)(NSArray* links))sharedLinks
            failure:(void (^)(NSError* error))failure;

- (void)linkForPath:(NSString*)path
            success:(void (^)(NSDictionary* info))success
            failure:(void (^)(NSError* error))failure;

- (void)setLinkTTL:(NSUInteger)ttl
    linkIdentifier:(NSString*)linkIdentifier
           success:(void(^)(void))success
           failure:(void(^)(NSError* error))failure;

- (void)deleteLink:(NSString*)linkIdentifier
           success:(void(^)(void))success
           failure:(void (^)(NSError* error))failure;

- (void)shareFolderAtPath:(NSString*)path
                     with:(NSArray*)emails
                  success:(void (^)(NSDictionary* info, NSError* error))success
                  failure:(void (^)(NSError* error))failure;

- (void)removeUserFromShareAtPath:(NSString*)path
                             user:(NSString*)userIdentifier
                          success:(void (^)(void))success
                          failure:(void (^)(NSError* error))failure;

- (void)shortURLForShare:(NSString*)shareIdentifier
                 success:(void (^)(NSString* url))success
                 failure:(void (^)(NSError* error))failure;

- (void)destroyShortURL:(NSString*)shortURL
                success:(void (^)(NSString* shareIdentifier))success
                failure:(void (^)(NSError* error))failure;

@end
