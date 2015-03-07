//
//  MEOCFile.h
//  MEOCloudApp
//
//  Created by Luís Silva on 24/01/15.
//
//

#import <Foundation/Foundation.h>

@interface MCMetadata : NSObject<NSCoding>
@property (nonatomic, strong) NSNumber* bytes;
@property (nonatomic, strong) NSString* uniqueIdentifier;
@property (nonatomic, assign) BOOL isDirectory;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, strong) NSDate* modified;
@property (nonatomic, strong) NSString* path;
@property (nonatomic, strong) NSString* filename;
@property (nonatomic, strong) NSString* revision;
@property (nonatomic, strong) NSString* root;
@property (nonatomic, strong) NSString* size;
@property (nonatomic, strong) NSString* mimeType;
@property (nonatomic, strong) NSString* icon;
@property (nonatomic, assign) BOOL hasThumbnail;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary NS_DESIGNATED_INITIALIZER;
@end
