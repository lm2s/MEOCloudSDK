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

/**
 *  `MCClient` error codes.
 */
typedef NS_ENUM(NSInteger, MCClientError){
    /**
     *  When a URL is invalid.
     */
    kInvalidURLError = -1,
    /**
     *  If an invalid short URL is given.
     */
    kRetrieveSubdomainError = -2,
    /**
     *  If a folder collaboration share fails.
     */
    kShareFolderFailed = -3,
    /**
     *  If a folder collaboration invitation partially fails.
     */
    kShareFolderPartialSuccess = -4,
    /**
     *  When an upload abort is requested.
     */
    kUploadAbortRequested = -5
};

/**
 *  Thumbnail sizes.
 */
typedef NS_ENUM(NSInteger, MCThumbnailSize){
    /**
     *  32x32
     */
    MCThumbnailSizeXS,
    /**
     *  64x64
     */
    MCThumbnailSizeS,
    /**
     *  120x120
     */
    MCThumbnailSizeM,
    /**
     *  640x640
     */
    MCThumbnailSizeL,
    /**
     *  1024x1024
     */
    MCThumbnailSizeXL
};

/**
 *  Thumbnail file format.
 */
typedef NS_ENUM(NSInteger, MCThumbnailFormat){
    /**
     *  JPEG
     */
    MCThumbnailFormatJPEG,
    /**
     *  PNG
     */
    MCThumbnailFormatPNG
};


/**
 * `MCClient` exposes the MEOCloud API functionality.
 *
 * It allows the retrieval of metadata, file and folder manipulation, file download and upload, 
 * generation of sharing links for files and folders, invitation of other users to collaborate in a 
 * folder, manipulation of shared folders options, etc.
 *
 * For use of this class, first create a session and then use the initWithSession method to
 * create an instance of this class.
 */
@interface MCClient : NSObject

/**
 *  Initializes an `MCClient` object with the specified session.
 *
 *  @param session The session for the client.
 *
 *  @return The newly initialized `MCClient`.
 */
- (instancetype)initWithSession:(MCSession*)session NS_DESIGNATED_INITIALIZER;

/**
 *  Retrieves the user account information.
 *
 *  @param accountInfo  A block to be executed when the operation is successful. This block has no 
 *                      return values and takes one argument: the `MCAccount` object that contains 
 *                      all of the user account information.
 *  @param failure      A block to be executed when the operation fails. This block has no return
 *                      values and takes one argument: the `NSError` object describing the error
 *                      that occurred.
 */
- (void)userAccountInfo:(void (^)(MCAccount* accountInfo))accountInfo failure:(void (^)(NSError* error))failure;

/**
 *  Retrieves the metadata at a certain path.
 *
 *  @param path     The path string from which the metadata is to be retrieved.
 *  @param success  A block to be executed when the operation is successful. This block has no 
 *                  return value and takes one argument: a `NSArray` containing all the metadata
 *                  retrieve.
 *  @param failure  A block to be executed when the operation fails. This block has no return
 *                  values and takes one argument: the `NSError` object describing the error
 *                  that occurred.
 */
- (void)metadataAtPath:(NSString*)path
               success:(void (^)(NSArray *metadata))success
               failure:(void (^)(NSError *error))failure;

// TODO
//- (void)metadataAtPath:(NSString*)path
//              contents:(BOOL)contents
//               success:(void (^)(NSArray *metadata))success
//               failure:(void (^)(NSError *error))failure;

/**
 *  Downloads a file from the MEOCloud, saving to a local temporary directory.
 *
 *  @param path     The path string pointing to the file in the MEOCloud.
 *  @param progress A block to be executed while the file is being downloaded. This block has no
 *                  return value and takes two arguments: `bytesRead` the total number of bytes 
 *                  downloaded, `bytesExpectedToRead` the file size in bytes.
 *  @param success  A block to be executed if the download is successful. This block has no return 
 *                  value and takes one argument: the local path to the downloaded file.
 *  @param failure  A block to be executed if the download fails. This blocks has no return value
 *                  and takes one argument: the error describing what caused the operation to fail.
 */
- (void)downloadFileAtPath:(NSString*)path
                  progress:(void (^)(long long bytesRead, long long bytesExpectedToRead))progress
                   success:(void (^)(NSString* path))success
                   failure:(void (^)(NSError* error))failure;

/**
 *  Resumes a file download.
 *
 *  @param path The path string pointing to the file (this path must be equal to the path string
 *              used in `downloadFileAtPath:progress:success:failure`).
 */
- (void)resumeFileDownloadAtPath:(NSString *)path;

/**
 *  Pauses a file currently being downloaded.
 *
 *  @param path The path string pointing to the file (this path must be equal to the path string
 *              used in `downloadFileAtPath:progress:success:failure`).
 */
- (void)pauseFileDownloadAtPath:(NSString*)path;

/**
 *  Cancels the download of a file.
 *
 *  @param path The path string pointing to the file (this path must be equal to the path string
 *              used in `downloadFileAtPath:progress:success:failure`).
 */
- (void)cancelFileDownloadAtPath:(NSString*)path;

/**
 *  Helper method to verify if a file was already downloaded and is cached.
 *
 *  @param path The path string pointing to the file in the MEOCloud.
 *
 *  @return `YES` if the file is cached, otherwise `NO`.
 */
- (BOOL)isFileCached:(NSString*)path;

/**
 *  Helper method to remove all files in cache.
 */
- (void)clearCachedFiles;

/**
 *  Retrieve a file thumbnail.
 *
 *  @param path     The path string pointing to the file.
 *  @param size     An option describing which size is preferable.
 *  @param format   The file type of the thumbnail (PNG or JPEG).
 *  @param crop     Should the thumbnail be cropped.
 *  @param success  A block to be executed when the operation is successful. This block has no 
 *                  return value and one argument: an `UIImage` representation of the thumbnail.
 *  @param failure  A block to be executed when the operation fails. This block has no return
 *                  values and takes one argument: the `NSError` object describing the error
 *                  that occurred.
 */
- (void)thumbnailAtPath:(NSString*)path
                   size:(MCThumbnailSize)size
                 format:(MCThumbnailFormat)format
                   crop:(BOOL)crop
                success:(void (^)(UIImage* thumbnail))success
                failure:(void (^)(NSError* error))failure;

/**
 *  Creates a folder in MEOCloud.
 *
 *  @param folder   The folder string describing its name.
 *  @param path     The path string pointing to where the folder is to be created.
 *  @param success  A block to be executed when the operation is successful. This block has no
 *                  return value and takes one argument: a dictionary containing the created folder
 *                  metadata.
 *  @param failure  A block to be executed when the operation fails. This block has no return
 *                  values and takes one argument: the `NSError` object describing the error
 *                  that occurred.
 */
- (void)createFolder:(NSString*)folder
              atPath:(NSString*)path
             success:(void (^)(NSDictionary* info))success
             failure:(void (^)(NSError* error))failure;
// TODO
//- (void)uploadToPath:(NSString*)path
//            filename:(NSString*)filename
//                data:(NSData*)data
//            progress:(void (^)(unsigned long long bytesUploaded, unsigned long long totalToBeUploaded))progress
//             success:(void (^)(NSDictionary *metadata))success
//             failure:(void (^)(NSError *error))failure;

/**
 *  Creates a file in the MEOCloud and uploads a stream of data into it.
 *
 *  @param path         The path string pointing to where the file is to be created.
 *  @param filename     The filename.
 *  @param overwrite    `YES` if an existing file with the same name is to be overwritten,
 *                      otherwise `NO`.
 *  @param identifier   The upload identifier string. Each upload is given an unique identifier
 *                      string, which is used to track that specific upload while it occurs.
 *  @param inputStream  A block to be executed while the operation is being executed, which feeds 
 *                      data to the upload operation. This block is expected to return `YES` while
 *                      there is data being fed, otherwise `NO`. This block takes four arguments:
 *                      the upload identifier string, the offset from which data is to be fed, 
 *                      the data to be uploaded, `YES` if the upload is to be aborted, 
 *                      otherwise `NO`.
 *  @param progress     A block to be executed while the operation is being executed. This block 
 *                      has no return value and takes three arguments: the upload identifier string,
 *                      the number of bytes uploaded and the total number of bytes to be uploaded.
 *  @param success      A block to be executed when the operation is successful. This block has no
 *                      return value and takes one argument: a dictionary the newly uploaded file
 *                      metadata.
 *  @param failure      A block to be executed when the operation fails. This block has no return
 *                      values and takes one argument: the `NSError` object describing the error
 *                      that occurred.
 */
- (void)uploadToPath:(NSString*)path
            filename:(NSString*)filename
           overwrite:(BOOL)overwrite
          identifier:(NSString*)identifier
         inputStream:(BOOL (^)(NSString* uploadIdentifier, long long offset, NSData **data, BOOL* abortUpload))inputStream
            progress:(void (^)(NSString* uploadIdentifier, unsigned long long bytesUploaded, unsigned long long totalToBeUploaded))progress
             success:(void (^)(NSDictionary *metadata))success
             failure:(void (^)(NSError *error))failure;

/**
 *  Deletes a file or folder from the MEOCloud.
 *
 *  @param path     The path string pointing to the file or folder in the MEOCloud.
 *  @param success  A block to be executed if the operation is successful. This block has no
 *                  return value and takes one argument: a dictionary containing deleted file or 
 *                  folder metadata.
 *  @param failure  A block to be executed if the operation fails. This block has no return
 *                  values and takes one argument: the `NSError` object describing the error
 *                  that occurred.
 */
- (void)deleteAtPath:(NSString*)path
             success:(void (^)(NSDictionary* metadata))success
             failure:(void (^)(NSError* error))failure;

/**
 *  Retrive a list of the shared folders.
 *
 *  @param sharedFolders    A block that is executed after the successful retrieval of the shared
 *                          folders information. An `NSArray` containing `MCShare` objects is 
 *                          passed in.
 *  @param failure          A block to be executed when the operation fails. This block has no 
 *                          return values and takes one argument: the `NSError` object describing 
 *                          the error that occurred.
 */
- (void)sharedFolders:(void (^)(NSArray* folders))sharedFolders
              failure:(void (^)(NSError*))failure;

/**
 *  Retrive a list of the shared by link files or folders.
 *
 *  @param sharedLinks  A block that is executed after the successful retrieval of the shared by
 *                      link file or folders information. An `NSArray` containing `MCLink`
 *                      objects is passed in.
 *  @param failure      A block to be executed when the operation fails. This block has no return
 *                      values and takes one argument: the `NSError` object describing the error
 *                      that occurred.
 */
- (void)sharedLinks:(void (^)(NSArray* links))sharedLinks
            failure:(void (^)(NSError* error))failure;

/**
 *  Share by link a file or folder, a link will be generated for public sharing.
 *
 *  @param path     The path string pointing to the file or folder.
 *  @param success  A block to be executed when the operation is successful. This block has no
 *                  return value and takes one argument: a dictionary containing the generated
 *                  link metadata.
 *  @param failure  A block to be executed when the operation fails. This block has no return
 *                  values and takes one argument: the `NSError` object describing the error
 *                  that occurred.
 */
- (void)linkForPath:(NSString*)path
            success:(void (^)(NSDictionary* info))success
            failure:(void (^)(NSError* error))failure;

/**
 *  Change the time of expiration of a share link.
 *
 *  @param ttl              The time in seconds for the link duration.
 *  @param linkIdentifier   The link identifier string.
 *  @param success          A block to be executed when the operation is successful. This block has
 *                          no return value and takes no argument.
 *  @param failure          A block to be executed when the operation fails. This block has no 
 *                          return values and takes one argument: the `NSError` object describing 
 *                          the error that occurred.
 */
- (void)setLinkTTL:(NSUInteger)ttl
    linkIdentifier:(NSString*)linkIdentifier
           success:(void(^)(void))success
           failure:(void(^)(NSError* error))failure;

/**
 *  Delete a share link.
 *
 *  @param linkIdentifier   The link identifier string.
 *  @param success          A block to be executed when the operation is successful. This block has
 *                          no return value and takes no argument.
 *  @param failure          A block to be executed when the operation fails. This block has no
 *                          return values and takes one argument: the `NSError` object describing
 *                          the error that occurred.
 */
- (void)deleteLink:(NSString*)linkIdentifier
           success:(void(^)(void))success
           failure:(void (^)(NSError* error))failure;

/**
 *  Invite users to collaborate in a folder.
 *
 *  @param path     The path string pointing to the folder.
 *  @param emails   The `NSArray` containing a the emails (as `NSString`) of the users to be 
 *                  invited.
 *  @param success  A block to be executed when the operation is successful (or partially
 *                  successful). This block takes two arguments: the info contains the metadata
 *                  of the new collaboration folder, the error will be nil if all users are 
 *                  successfully invited, otherwise it will contain information about which emails
 *                  failed.
 *  @param failure  A block to be executed when the operation fails. This block has no
 *                  return values and takes one argument: the `NSError` object describing
 *                  the error that occurred.
 */
- (void)shareFolderAtPath:(NSString*)path
                     with:(NSArray*)emails
                  success:(void (^)(NSDictionary* info, NSError* error))success
                  failure:(void (^)(NSError* error))failure;

/**
 *  Removes a user from a collaboration folder.
 *
 *  @param path             The path string pointing to the collaboration folder.
 *  @param userIdentifier   The user identifier string.
 *  @param success          A block to be executed when the operation is successful. This block has
 *                          no return value and takes no argument.
 *  @param failure          A block to be executed when the operation fails. This block has no
 *                          return values and takes one argument: the `NSError` object describing
 *                          the error that occurred.
 */
- (void)removeUserFromShareAtPath:(NSString*)path
                             user:(NSString*)userIdentifier
                          success:(void (^)(void))success
                          failure:(void (^)(NSError* error))failure;

/**
 *  Retrieve, or create if none exists yet, a short URL for a share by link of a file or folder.
 *
 *  @param shareIdentifier  The share identifier string.
 *  @param success          A block to be executed when the operation is successful. This block 
 *                          takes one argument: the short url string.
 *  @param failure          A block to be executed when the operation fails. This block has no
 *                          return values and takes one argument: the `NSError` object describing
 *                          the error that occurred.
 */
- (void)shortURLForShare:(NSString*)shareIdentifier
                 success:(void (^)(NSString* url))success
                 failure:(void (^)(NSError* error))failure;

/**
 *  Destroy a short URL.
 *
 *  @param shortURL The short URL string.
 *  @param success  A block to be executed when the operation is successful. This block takes one 
 *                  argument: the identifer of the share to which the short URL was pointing.
 *  @param failure  A block to be executed when the operation fails. This block has no
 *                  return values and takes one argument: the `NSError` object describing
 *                  the error that occurred.
 */
- (void)destroyShortURL:(NSString*)shortURL
                success:(void (^)(NSString* shareIdentifier))success
                failure:(void (^)(NSError* error))failure;

@end
